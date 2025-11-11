import 'package:flutter/material.dart';
import '../modelsData/room_data.dart';
import '../services/api_service.dart';

// ใน room_detail_page.dart

class RoomDetailPage extends StatelessWidget { // 👈 เปลี่ยนเป็น StatelessWidget ได้เลย
  final String title;
  final UserRole userRole;
  final List<RoomSlot> uniqueRooms;
  final Map<String, List<RoomSlot>> allSlotsByRoom;
  final void Function(RoomSlot)? onSlotSelected;

  const RoomDetailPage({
    super.key,
    required this.title,
    required this.userRole,
    required this.uniqueRooms,
    required this.allSlotsByRoom,
    this.onSlotSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: const Color(0xFF6A994E),
      ),
      backgroundColor: const Color(0xFFE6D5A9),
      body: uniqueRooms.isEmpty
          ? const Center(
              child: Text(
                'No rooms available for this type.',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.builder(
                itemCount: uniqueRooms.length,
                itemBuilder: (context, index) {
                  final room = uniqueRooms[index];
                  final slotsForThisRoom = allSlotsByRoom[room.room] ?? [];

                  // ต่อ URL เต็ม
                  var imageUrl = room.imageUrl;
                  if (imageUrl != null && !imageUrl.startsWith('http')) {
                    imageUrl = '${ApiService.base}$imageUrl';
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (dialogContext) {
                            if (userRole == UserRole.staff) {
                              return AlertDialog(
                                title: Text(room.room),
                                content: const Text('What would you like to do?'),
                                actionsAlignment: MainAxisAlignment.spaceBetween,
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(dialogContext).pop(),
                                    child: const Text('Close'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(dialogContext).pop();
                                      onSlotSelected?.call(room);
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Edit'),
                                  ),
                                ],
                              );
                            } else { // สำหรับ User/Student
                              return AlertDialog(
                                title: Text(room.room),
                                content: SizedBox(
                                  width: double.maxFinite,
                                  height: 250,
                                  child: ListView.builder(
                                    itemCount: slotsForThisRoom.length,
                                    itemBuilder: (context, i) {
                                      final slot = slotsForThisRoom[i];
                                      final bool isFree = slot.status == 'Free';
                                      return Opacity(
                                        opacity: isFree ? 1.0 : 0.5,
                                        child: ListTile(
                                          title: Text(slot.timeSlots),
                                          trailing: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: slot.statusColor,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(slot.status, style: const TextStyle(color: Colors.white)),
                                          ),
                                          onTap: isFree
                                              ? () {
                                                  onSlotSelected?.call(slot);
                                                  Navigator.of(dialogContext).pop();
                                                  Navigator.of(context).pop();
                                                }
                                              : null,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(dialogContext).pop(),
                                    child: const Text('Close'),
                                  ),
                                ],
                              );
                            }
                          },
                        );
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          imageUrl!,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}