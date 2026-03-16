import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/theme/app_theme.dart';

/// Debug screen to view all activation keys and relationships in the database
/// This helps verify that party member and support member registration is working correctly
class DebugKeysScreen extends StatefulWidget {
  const DebugKeysScreen({super.key});

  @override
  State<DebugKeysScreen> createState() => _DebugKeysScreenState();
}

class _DebugKeysScreenState extends State<DebugKeysScreen> {
  String _selectedTab = 'party'; // 'party' or 'support'

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              // App Bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios_rounded,
                          color: AppTheme.textPrimary),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text('Debug: Database View',
                          style: AppTheme.headingSmall),
                    ),
                  ],
                ),
              ),

              // Tab Selector
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppTheme.cardDark,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.cardBorder),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildTab(
                          label: 'Party Members',
                          icon: Icons.person_rounded,
                          isSelected: _selectedTab == 'party',
                          onTap: () => setState(() => _selectedTab = 'party'),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: _buildTab(
                          label: 'Support Members',
                          icon: Icons.group_rounded,
                          isSelected: _selectedTab == 'support',
                          onTap: () => setState(() => _selectedTab = 'support'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Content
              Expanded(
                child: _selectedTab == 'party'
                    ? _buildPartyMembersView()
                    : _buildSupportMembersView(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTab({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: isSelected ? AppTheme.saffronGradient : null,
          color: isSelected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                color: isSelected ? Colors.white : AppTheme.textSecondary,
                size: 18),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTheme.bodyMedium.copyWith(
                color: isSelected ? Colors.white : AppTheme.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPartyMembersView() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('partyMembers')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.accentSaffron),
          );
        }

        if (snapshot.hasError) {
          return _buildErrorView(snapshot.error.toString());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyView(
            'No party members registered yet',
            'Register a party member first to see activation keys here',
          );
        }

        final docs = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final uid = docs[index].id;
            return _buildPartyMemberCard(uid, data);
          },
        );
      },
    );
  }

  Widget _buildPartyMemberCard(String uid, Map<String, dynamic> data) {
    final name = data['name'] ?? 'Unknown';
    final email = data['email'] ?? 'No email';
    final activationKey = data['activationKey'] ?? 'NO KEY';
    final party = data['party'] ?? 'No party';
    final village = data['village'] ?? 'No village';
    final wardNumber = data['wardNumber'] ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: AppTheme.saffronGradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.person_rounded,
                    color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: AppTheme.headingSmall.copyWith(fontSize: 16)),
                    Text(email,
                        style: AppTheme.bodyMedium.copyWith(fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // UID
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryDark.withAlpha(100),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.fingerprint_rounded,
                    color: AppTheme.textSecondary, size: 14),
                const SizedBox(width: 6),
                Expanded(
                  child: Text('UID: $uid',
                      style: AppTheme.bodyMedium.copyWith(
                        fontSize: 11,
                        fontFamily: 'monospace',
                      )),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Activation Key (Prominent)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryDark,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.accentSaffron, width: 2),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.key_rounded,
                        color: AppTheme.accentSaffron, size: 20),
                    const SizedBox(width: 8),
                    Text('Activation Key',
                        style: AppTheme.bodyMedium.copyWith(fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      activationKey,
                      style: AppTheme.headingMedium.copyWith(
                        letterSpacing: 4,
                        color: AppTheme.accentSaffron,
                        fontSize: 22,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: activationKey));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Copied: $activationKey',
                                style: AppTheme.bodyMedium
                                    .copyWith(color: Colors.white)),
                            backgroundColor: AppTheme.accentGreen,
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      icon: const Icon(Icons.copy_rounded,
                          color: AppTheme.accentSaffron, size: 20),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Details
          _buildDetailRow(Icons.flag_rounded, 'Party', party),
          _buildDetailRow(Icons.location_on_rounded, 'Village', village),
          _buildDetailRow(Icons.numbers_rounded, 'Ward', wardNumber.toString()),

          // Support Members Count
          const SizedBox(height: 12),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('supportMembers')
                .where('linkedPartyMemberUid', isEqualTo: uid)
                .snapshots(),
            builder: (context, supportSnapshot) {
              final count =
                  supportSnapshot.hasData ? supportSnapshot.data!.docs.length : 0;
              return Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.accentGreen.withAlpha(20),
                  borderRadius: BorderRadius.circular(8),
                  border:
                      Border.all(color: AppTheme.accentGreen.withAlpha(60)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.group_rounded,
                        color: AppTheme.accentGreen, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      '$count Support Member${count != 1 ? 's' : ''} linked',
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.accentGreen,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSupportMembersView() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('supportMembers')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.accentGreen),
          );
        }

        if (snapshot.hasError) {
          return _buildErrorView(snapshot.error.toString());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyView(
            'No support members registered yet',
            'Support members will appear here after registration',
          );
        }

        final docs = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final uid = docs[index].id;
            return _buildSupportMemberCard(uid, data);
          },
        );
      },
    );
  }

  Widget _buildSupportMemberCard(String uid, Map<String, dynamic> data) {
    final name = data['name'] ?? 'Unknown';
    final email = data['email'] ?? 'No email';
    final activationKey = data['activationKey'] ?? 'NO KEY';
    final linkedUid = data['linkedPartyMemberUid'] ?? 'NO LINK';
    final party = data['party'] ?? 'No party';
    final village = data['village'] ?? 'No village';
    final wardNumber = data['wardNumber'] ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: AppTheme.greenGradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.group_rounded,
                    color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: AppTheme.headingSmall.copyWith(fontSize: 16)),
                    Text(email,
                        style: AppTheme.bodyMedium.copyWith(fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Used Activation Key
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryDark,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.cardBorder),
            ),
            child: Row(
              children: [
                const Icon(Icons.key_rounded,
                    color: AppTheme.accentSaffron, size: 18),
                const SizedBox(width: 8),
                Text('Used Key: ',
                    style: AppTheme.bodyMedium.copyWith(fontSize: 12)),
                Text(
                  activationKey,
                  style: AppTheme.bodyLarge.copyWith(
                    letterSpacing: 2,
                    color: AppTheme.accentSaffron,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Linked Party Member
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('partyMembers')
                .doc(linkedUid)
                .snapshots(),
            builder: (context, partySnapshot) {
              if (!partySnapshot.hasData || !partySnapshot.data!.exists) {
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.errorRed.withAlpha(20),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.errorRed.withAlpha(60)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_rounded,
                          color: AppTheme.errorRed, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '⚠️ Linked party member not found!',
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.errorRed,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              final partyData =
                  partySnapshot.data!.data() as Map<String, dynamic>;
              final partyName = partyData['name'] ?? 'Unknown';

              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.accentGreen.withAlpha(20),
                  borderRadius: BorderRadius.circular(10),
                  border:
                      Border.all(color: AppTheme.accentGreen.withAlpha(60)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.link_rounded,
                            color: AppTheme.accentGreen, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Supporting: $partyName',
                          style: AppTheme.bodyLarge.copyWith(
                            color: AppTheme.accentGreen,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Party Member UID: $linkedUid',
                      style: AppTheme.bodyMedium.copyWith(
                        fontSize: 10,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 12),

          // Details
          _buildDetailRow(Icons.flag_rounded, 'Party', party),
          _buildDetailRow(Icons.location_on_rounded, 'Village', village),
          _buildDetailRow(Icons.numbers_rounded, 'Ward', wardNumber.toString()),
        ],
      ),
    );
  }

  Widget _buildErrorView(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded,
                color: AppTheme.errorRed, size: 60),
            const SizedBox(height: 16),
            Text('Error: $error',
                style: AppTheme.bodyMedium, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text('Check console for details',
                style: AppTheme.bodyMedium.copyWith(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyView(String title, String subtitle) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inbox_rounded,
                color: AppTheme.textSecondary, size: 60),
            const SizedBox(height: 16),
            Text(title, style: AppTheme.bodyLarge),
            const SizedBox(height: 8),
            Text(subtitle,
                style: AppTheme.bodyMedium, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.textSecondary, size: 16),
          const SizedBox(width: 8),
          Text('$label: ', style: AppTheme.bodyMedium.copyWith(fontSize: 13)),
          Text(value,
              style: AppTheme.bodyLarge
                  .copyWith(fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
