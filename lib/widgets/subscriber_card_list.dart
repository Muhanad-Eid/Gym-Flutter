import 'package:flutter/material.dart';
import 'package:gym/screens/subscribers.dart';

class SubscriberCardList extends StatelessWidget {
  final List<Subscriber> subscribers;
  final Function(Subscriber) onEdit;
  final Function(Subscriber) onDelete;
  final Function(Subscriber) onTap;

  const SubscriberCardList({
    super.key,
    required this.subscribers,
    required this.onEdit,
    required this.onDelete,
    required this.onTap,
  });

  Color _getStatusColor(Subscriber s) {
    if (s.isExpired) return Colors.red;
    if (s.isExpiringSoon) return Colors.orange;
    return Colors.green;
  }

  String _getStatusText(Subscriber s) {
    if (s.isExpired) return 'Expired';
    if (s.isExpiringSoon) return '${s.daysRemaining} days left';
    return '${s.daysRemaining} days';
  }

  @override
  Widget build(BuildContext context) {
    if (subscribers.isEmpty) {
      return const Center(child: Text('No subscribers found'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: subscribers.length,
      itemBuilder: (context, i) {
        final s = subscribers[i];
        final statusColor = _getStatusColor(s);
        final statusText = _getStatusText(s);

        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: statusColor.withOpacity(0.3), width: 2),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.deepPurple,
              child: Text(
                s.firstName.isNotEmpty ? s.firstName[0].toUpperCase() : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    s.fullName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor, width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        s.isExpired
                            ? Icons.cancel
                            : (s.isExpiringSoon
                                  ? Icons.warning
                                  : Icons.check_circle),
                        size: 14,
                        color: statusColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text('${s.phoneNumber} • ${s.membershipType}'),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.orange),
                  onPressed: () => onEdit(s),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => onDelete(s),
                ),
              ],
            ),
            onTap: () => onTap(s),
          ),
        );
      },
    );
  }
}
