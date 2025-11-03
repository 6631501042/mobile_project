const express = require('express');
const argon2 = require('@node-rs/argon2');
const con = require('./db');
const app = express();

app.use(express.json());

//========================== student ======================================

//------------------- Get specific room --------------
app.get("/api/student/rooms/:roomID", (req, res) => {
  const roomID = req.params.roomID;
  const sql = "SELECT * FROM rooms WHERE id = ?";
  con.query(sql, [roomID], function (err, result) {
    if (err) {
      console.error(err.message);
      return res.status(500).send("Database server error");
    }
    res.json(result);
  });
});

// //------------------- Get my reserved rooms (history) --------------
// app.get("/api/student/history/:roleID", (req, res) => {
//   const roleID = req.params.roleID;
//   const sql = "SELECT * FROM history WHERE role_id = ?";
//   con.query(sql, [roleID], function (err, result) {
//     if (err) {
//       console.error(err.message);
//       return res.status(500).send("Database server error");
//     }
//     res.json(result);
//   });
// });

//------------------- Add new account (Register) --------------
app.post("/api/student/register", async (req, res) => {
  try {
    const { username, password } = req.body;
    if (!username || !password)
      return res.status(400).send("Missing username or password");

    // hash password
    const hashed = await argon2.hash(password);
    const sql = "INSERT INTO roles(username, password, role) VALUES (?, ?, 'student')";
    con.query(sql, [username, hashed], function (err, result) {
      if (err) {
        console.error(err.message);
        return res.status(500).send("Database server error");
      }
      if (result.affectedRows != 1) {
        return res.status(500).send("Failed to register");
      }
      res.send('Student registered successfully');
    });
  } catch (e) {
    console.error(e.message);
    res.status(500).send("Server error");
  }
});

//------------------- Reserve room --------------
app.put("/api/student/rooms/:roomID", (req, res) => {
  const roomID = req.params.roomID;
  const { role_id } = req.body;
  if (!role_id) return res.status(400).send("Missing role_id");

  const sql = `
    UPDATE rooms 
    SET role_id = ?, status = 'pending'
    WHERE id = ? AND status = 'free'
  `;

  con.query(sql, [role_id, roomID], function (err, result) {
    if (err) {
      console.error(err.message);
      return res.status(500).send("Database server error");
    }
    if (result.affectedRows != 1) {
      return res.status(400).send("Room not available or already reserved");
    }

    // Log reservation into history
    const logSql = `
      INSERT INTO history (role_id, room_id, approver_id, reserved_date, status, reason)
      VALUES (?, ?, ?, CURDATE(), 'approved', '')
    `;
    con.query(logSql, [role_id, roomID], (logErr) => {
      if (logErr) console.error("Failed to log history:", logErr.message);
    });

    res.send('Room reserved successfully');
  });
});

//========================== staff ======================================

//-------------------------- Get all students ------------------------
app.get("/api/staff/roles", (_req, res) => {
  const sql = "SELECT id, username FROM roles WHERE role = 'student'";
  con.query(sql, (err, result) => {
    if (err) {
      console.error(err.message);
      return res.status(500).send("Database server error");
    }
    res.json(result);
  });
});

//========================== Common APIs =================================
//-------------------------- Get all users ------------------------
// app.get("/api/admin/users",(_req, res) => {
//     const sql = "SELECT id, username FROM users WHERE role = 'user'";
//     con.query(sql, (err, result) => {
//         if (err) {
//             console.error(err.message);
//             return res.status(500).send("Database server error");
//         }
//         res.json(result);
//     });
// });
//-------------------------- password generator ------------------------
// app.get('/api/password/:raw', (req, res) => {
//   const raw = req.params.raw;
//   const hash = argon2.hashSync(raw);
//   res.send(hash);
// });

//-------------------------- login ------------------------
app.post('/api/login', (req, res) => {
  const { username, password } = req.body;
  const sql = "SELECT id, username, password, role FROM roles WHERE username = ?";
  con.query(sql, [username], async (err, results) => {
    if (err) return res.status(500).send("Database server error");
    if (results.length !== 1) return res.status(401).send("Wrong username");

    const ok = await argon2.verify(results[0].password, password);
    if (!ok) return res.status(401).send("Wrong password");

    res.json({
      role_id: results[0].id,
      username: results[0].username,
      role: results[0].role
    });
  });
});


app.get("/api/student/history/:roleID", (req, res) => {
  const roleID = req.params.roleID;
  const sql = `
    SELECT
      LPAD(h.id, 6, '0') AS req_id_padded,
      r.username,
      rm.roomname AS roomCode,
      DATE_FORMAT(h.reserved_date, '%d %b %Y') AS dateText,
      rm.timeslot AS timeText,
      CASE WHEN h.status='approved' THEN 'Approved' ELSE 'Rejected' END AS statusText,
      h.reason AS rejectReason,
      a.username AS approverName           -- 👈 add this
    FROM history h
    JOIN roles r ON r.id = h.role_id
    JOIN rooms rm ON rm.id = h.room_id
    LEFT JOIN roles a ON a.id = h.approver_id
    WHERE h.role_id = ?
      AND h.status IN ('approved','rejected')   -- hide pending
    ORDER BY h.reserved_date DESC, rm.timeslot ASC
  `;

  con.query(sql, [roleID], (err, rows) => {
    if (err) return res.status(500).send("Database server error");
    const payload = rows.map(row => ({
      reqIdAndUser: `${row.req_id_padded}/${row.username}`,
      roomCode: row.roomCode,
      date: row.dateText,
      time: row.timeText,
      status: row.statusText,
      approverName: row.approverName || "—",    // 👈 now real approver (id=29 in your data)
      rejectReason: row.rejectReason || ""
    }));
    res.json(payload);
  });
});

//=================== Starting server =======================
const port = 3000;
app.listen(port, () => {
  console.log('Server is running at port ' + port);
});
