import 'package:flutter/material.dart';
import 'package:turathi/core/services/gym_service.dart';
import 'package:turathi/core/models/member_model.dart';
import 'package:turathi/view/screens/register/sign_up.dart';
import 'package:turathi/view/screens/profile_screens/screens/member_details_screen.dart';
import 'package:intl/intl.dart';
import 'dart:developer';

class MembersScreen extends StatefulWidget {
  const MembersScreen({Key? key}) : super(key: key);

  @override
  State<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends State<MembersScreen> {
  final GymService _gymService = GymService();
  late Future<List<MemberModel>> _membersFuture;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Active', 'Expired', 'Expiring Soon'];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _refreshMembers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _refreshMembers() {
    setState(() {
      _isLoading = true;
      _membersFuture = _gymService.getMembers().then((members) {
        log('Successfully fetched ${members.length} members');
        for (var member in members) {
          log('Member: ${member.name}, ID: ${member.id}, Status: ${member.status}');
        }
        _isLoading = false;
        return members;
      }).catchError((error) {
        _isLoading = false;
        log('Error fetching members: $error', error: error, stackTrace: StackTrace.current);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading members: ${error.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
        throw error;
      });
    });
  }

  Future<void> _navigateToSignUp() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SingUp(isAdminAdd: true)),
    );
    _refreshMembers();
  }

  void _navigateToMemberDetails(MemberModel member) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MemberDetailsScreen(
          member: member,
          isAdmin: true,
        ),
      ),
    ).then((_) => _refreshMembers());
  }

  List<MemberModel> _filterMembers(List<MemberModel> members) {
    return members.where((member) {
      // Search query matching
      final searchLower = _searchQuery.toLowerCase();
      final matchesSearch = 
          (member.name?.toLowerCase().contains(searchLower) ?? false) ||
          (member.registrationNumber?.toLowerCase().contains(searchLower) ?? false) ||
          (member.phone?.contains(_searchQuery) ?? false);

      if (!matchesSearch) return false;

      // Status filtering
      final now = DateTime.now();
      final thirtyDaysFromNow = now.add(const Duration(days: 30));
      
      switch (_selectedFilter) {
        case 'Active':
          return (member.status?.toLowerCase() == 'active' || member.status == null) && 
                 (member.expiryDate?.isAfter(now) ?? false);
        case 'Expired':
          return member.expiryDate?.isBefore(now) ?? false;
        case 'Expiring Soon':
          return (member.expiryDate?.isBefore(thirtyDaysFromNow) ?? false) &&
                 (member.expiryDate?.isAfter(now) ?? false);
        default:
          return true;
      }
    }).toList();
  }

  Widget _buildMemberCard(MemberModel member) {
    final bool isExpired = member.expiryDate?.isBefore(DateTime.now()) ?? false;
    final bool isExpiringSoon = member.expiryDate?.isBefore(
      DateTime.now().add(const Duration(days: 30))
    ) ?? false;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _navigateToMemberDetails(member),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF2C0000).withOpacity(0.9),
                Colors.black.withOpacity(0.8),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: Text(
                      member.name?.substring(0, 1).toUpperCase() ?? 'M',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          member.name ?? 'Unknown Member',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Reg#: ${member.registrationNumber ?? 'N/A'}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isExpired 
                          ? Colors.red 
                          : isExpiringSoon 
                              ? Colors.orange 
                              : Colors.green,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isExpired 
                          ? 'Expired' 
                          : isExpiringSoon 
                              ? 'Expiring Soon' 
                              : 'Active',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildInfoChip(Icons.phone, member.phone ?? 'N/A'),
                  const SizedBox(width: 8),
                  _buildInfoChip(Icons.card_membership, member.membershipType ?? 'N/A'),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildInfoChip(
                    Icons.calendar_today,
                    member.joinDate != null 
                        ? DateFormat('MMM d, y').format(member.joinDate!)
                        : 'N/A',
                  ),
                  const SizedBox(width: 8),
                  _buildInfoChip(
                    Icons.event_busy,
                    member.expiryDate != null 
                        ? DateFormat('MMM d, y').format(member.expiryDate!)
                        : 'N/A',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white.withOpacity(0.7)),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Members',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF2C0000),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _navigateToSignUp,
            tooltip: 'Add New Member',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF2C0000),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search members...',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                    prefixIcon: const Icon(Icons.search, color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
                const SizedBox(height: 12),
                // Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _filters.map((filter) {
                      final isSelected = filter == _selectedFilter;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(
                            filter,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.white70,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedFilter = filter;
                            });
                          },
                          backgroundColor: Colors.white.withOpacity(0.1),
                          selectedColor: const Color(0xFF2C0000),
                          checkmarkColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          // Members List
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF2C0000),
                    Colors.black,
                  ],
                ),
              ),
              child: FutureBuilder<List<MemberModel>>(
                future: _membersFuture,
                builder: (context, snapshot) {
                  if (_isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    );
                  }
                  
                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error loading members',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: _refreshMembers,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2C0000),
                            ),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  final members = snapshot.data ?? [];
                  final filteredMembers = _filterMembers(members);

                  if (filteredMembers.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 64,
                            color: Colors.white.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery.isNotEmpty
                                ? 'No members found matching "$_searchQuery"'
                                : _selectedFilter != 'All'
                                    ? 'No members found with status "$_selectedFilter"'
                                    : 'No members found in the database',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Try adding a new member using the + button',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          if (_searchQuery.isNotEmpty || _selectedFilter != 'All')
                            Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  setState(() {
                                    _searchQuery = '';
                                    _selectedFilter = 'All';
                                    _searchController.clear();
                                  });
                                },
                                icon: const Icon(Icons.clear_all),
                                label: const Text('Clear filters'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2C0000),
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: filteredMembers.length,
                    itemBuilder: (context, index) {
                      return _buildMemberCard(filteredMembers[index]);
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToSignUp,
        backgroundColor: const Color(0xFF2C0000),
        child: const Icon(Icons.add),
      ),
    );
  }
} 