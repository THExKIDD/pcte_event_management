import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:pcte_event_management/Api_Calls/class_api.dart';
import 'package:pcte_event_management/LocalStorage/Secure_Store.dart';
import 'package:pcte_event_management/ui/class_screen.dart';

import '../Models/class_model.dart';

class ClassScreen extends StatefulWidget {
  @override
  _ClassScreenState createState() => _ClassScreenState();
}

class _ClassScreenState extends State<ClassScreen> {
  late Future<List<ClassModel>> _classesFuture;
  String? tkn;
  // Single filter state
  String _classTypeFilter = 'all'; // 'all', 'junior', or 'senior'
  final TextEditingController searchController = TextEditingController();
  final ValueNotifier<String> searchQuery = ValueNotifier<String>('');
  final ValueNotifier<String> filterStatus = ValueNotifier<String>('all');

  @override
  void initState() {
    super.initState();
    _classesFuture = ApiService.getAllClasses();
    log(_classesFuture.toString());
  }

  Future<void> token() async {
    SecureStorage secureStorage = SecureStorage();
    tkn = await secureStorage.getData('jwtToken');
    log(tkn!);
  }

  @override
  Widget build(BuildContext context) {
    // Get screen size for responsive design
    final Size screenSize = MediaQuery.of(context).size;
    final bool isSmallScreen = screenSize.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Classes",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 22)),
        elevation: 0,
        backgroundColor: Color(0xFF9E2A2F),
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics_outlined, color: Colors.white),
            onPressed: () {
              // Navigate to analytics
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white),
            onPressed: () {
              // Navigate to settings
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.indigo[50]!, Colors.white],
            stops: const [0.0, 0.3],
          ),
        ),
        child: Column(
          children: [
            // Search and filter container with stylized design
            Container(
              padding: EdgeInsets.fromLTRB(
                  20,
                  16,
                  20,
                  isSmallScreen ? 16 : 20 // Responsive padding
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(13),
                    spreadRadius: 1,
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Search bar with improved design
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!, width: 1),
                    ),
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: 'Search classes by name...',
                        hintStyle: TextStyle(color: Colors.grey[500], fontSize: 15),
                        prefixIcon: Icon(Icons.search, color: Colors.indigo[400], size: 22),
                        suffixIcon: ValueListenableBuilder<String>(
                          valueListenable: searchQuery,
                          builder: (context, query, _) {
                            return query.isNotEmpty
                                ? IconButton(
                              icon: Icon(Icons.clear, color: Colors.grey[600], size: 20),
                              onPressed: () {
                                searchController.clear();
                                searchQuery.value = '';
                              },
                            )
                                : const SizedBox.shrink();
                          },
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                      ),
                      onChanged: (value) {
                        searchQuery.value = value;
                      },
                    ),
                  ),

                  // Add unified class type filter chips
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildFilterChip('All Classes', 'all'),
                        SizedBox(width: 10),
                        _buildFilterChip('Junior', 'junior'),
                        SizedBox(width: 10),
                        _buildFilterChip('Senior', 'senior'),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Classes grid with improved styling
            Expanded(
              child: FutureBuilder<List<ClassModel>>(
                future: _classesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildLoadingState();
                  } else if (snapshot.hasError) {
                    return _buildErrorState(screenSize);
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return _buildEmptyState(screenSize);
                  } else {
                    final allClasses = snapshot.data!;
                    return _buildClassesGrid(allClasses, isSmallScreen);
                  }
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Add action to create a new class
        },
        tooltip: "Add New Class",
        backgroundColor: Color(0xFF9E2A2F),
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.add),
        label: const Text("New Class"),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  // Filter chip builder to avoid repetition
  Widget _buildFilterChip(String label, String value) {
    return FilterChip(
      label: Text(label),
      selected: _classTypeFilter == value,
      onSelected: (selected) {
        setState(() {
          _classTypeFilter = value;
        });
      },
      backgroundColor: Colors.grey[200],
      selectedColor: Color(0xFF9E2A2F).withAlpha(51), // Replaced withOpacity(0.2)
      labelStyle: TextStyle(
        color: _classTypeFilter == value ? Color(0xFF9E2A2F) : Colors.grey[800],
        fontWeight: _classTypeFilter == value ? FontWeight.bold : FontWeight.normal,
      ),
      checkmarkColor: Color(0xFF9E2A2F),
    );
  }

  // Loading state widget
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Color(0xFF9E2A2F)),
          const SizedBox(height: 16),
          Text(
            "Loading your classes...",
            style: TextStyle(
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  // Error state widget
  Widget _buildErrorState(Size screenSize) {
    return Center(
      child: Container(
        width: screenSize.width * 0.8,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(13),
              spreadRadius: 1,
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 70, color: Colors.red[400]),
            const SizedBox(height: 16),
            Text(
              "Oops! Something went wrong",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.red[700],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              "We couldn't load your classes. Please try again later.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[700]),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _classesFuture = ApiService.getAllClasses();
                });
              },
              icon: const Icon(Icons.refresh),
              label: const Text("Try Again"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Empty state widget
  Widget _buildEmptyState(Size screenSize) {
    return Center(
      child: Container(
        width: screenSize.width * 0.8,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(13),
              spreadRadius: 1,
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.class_outlined, size: 80, color: Colors.indigo[300]),
            const SizedBox(height: 16),
            Text(
              "No Classes Yet",
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.indigo[700],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              "Create your first class by tapping the + button below",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // Create class action
              },
              icon: const Icon(Icons.add),
              label: const Text("Create Class"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF9E2A2F),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Classes grid builder
  Widget _buildClassesGrid(List<ClassModel> allClasses, bool isSmallScreen) {
    return ValueListenableBuilder<String>(
      valueListenable: searchQuery,
      builder: (context, query, _) {
        return ValueListenableBuilder<String>(
          valueListenable: filterStatus,
          builder: (context, status, _) {
            // Single unified filter for classes
            final filteredClasses = allClasses.where((classItem) {
              // Apply all filters at once
              bool statusMatch = true;
              bool typeMatch = true;
              bool searchMatch = true;

              // Status filter
              if (status != 'all') {
                final bool isActive = classItem.isActive == true;
                statusMatch = (status == 'active' && isActive) || (status == 'inactive' && !isActive);
              }

              // Class type filter
              if (_classTypeFilter != 'all') {
                final String classType = (classItem.type ?? "").toLowerCase();
                typeMatch = _classTypeFilter == classType;
              }

              // Search query filter
              if (query.isNotEmpty) {
                searchMatch = classItem.name?.toLowerCase().contains(query.toLowerCase()) ?? false;
              }

              return statusMatch && typeMatch && searchMatch;
            }).toList();

            if (filteredClasses.isEmpty) {
              return _buildNoMatchesState();
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildClassesHeader(filteredClasses),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // Always show 2 columns regardless of screen size
                      crossAxisSpacing: 12, // Reduced spacing
                      mainAxisSpacing: 12, // Reduced spacing
                      childAspectRatio: isSmallScreen ? 1.1 : 1.0, // Adjusted ratio for smaller cards
                    ),
                    itemCount: filteredClasses.length,
                    itemBuilder: (context, index) {
                      return _buildClassCard(filteredClasses[index], query);
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Classes header with count and sort
  Widget _buildClassesHeader(List<ClassModel> classes) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "${classes.length} ${classes.length == 1 ? 'Class' : 'Classes'}",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Colors.grey[800],
            ),
          ),

        ],
      ),
    );
  }

  // No matches state widget
  Widget _buildNoMatchesState() {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(13),
              spreadRadius: 1,
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 70, color: Colors.amber[700]),
            const SizedBox(height: 16),
            Text(
              "No Matching Classes",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              "Try a different search term or filter",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: () {
                searchController.clear();
                searchQuery.value = '';
                filterStatus.value = 'all';
                setState(() {
                  _classTypeFilter = 'all';
                });
              },
              icon: const Icon(Icons.clear),
              label: const Text("Clear Filters"),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.indigo,
                side: const BorderSide(color: Colors.indigo),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Single class card widget
  Widget _buildClassCard(ClassModel classItem, String query) {
    final bool isActive = classItem.isActive == true;
    final Color typeColor = _getColorForClassType(classItem.type);

    return GestureDetector(
      onTap: () {
        // Handle card tap - navigate to details
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12), // Reduced border radius
          boxShadow: [
            BoxShadow(
              color: typeColor.withAlpha(51),
              spreadRadius: 1,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with icon and status badge
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10, // Reduced padding
              ),
              decoration: BoxDecoration(
                color: typeColor.withAlpha(38),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6), // Smaller icon container
                    decoration: BoxDecoration(
                      color: typeColor.withAlpha(230),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getIconForClassType(classItem.type),
                      color: Colors.white,
                      size: 16, // Smaller icon
                    ),
                  ),
                  // Status badge with flexible width
                  Container(
                    constraints: const BoxConstraints(minWidth: 60), // Smaller badge
                    height: 24, // Smaller badge height
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isActive
                          ? Colors.green[600]
                          : Colors.red[400],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isActive ? "Active" : "Inactive",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 10, // Smaller text
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            // Content with improved layout
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 6), // Reduced padding
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Class name with search highlighting
                    RichText(
                      text: _highlightMatches(
                        classItem.name ?? "Untitled Class",
                        query,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 4), // Reduced spacing

                    // Class type with better styling
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2, // Smaller type badge
                      ),
                      decoration: BoxDecoration(
                        color: typeColor.withAlpha(26),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        classItem.type ?? "General",
                        style: TextStyle(
                          color: typeColor.withAlpha(204),
                          fontSize: 10, // Smaller text
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    const Spacer(),

                    // Action buttons with improved layout and tooltips
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        OutlinedButton(
                          onPressed: () {
                            // Navigate to students list
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 0,
                            ),
                            minimumSize: const Size(0, 28), // Smaller button
                            side: BorderSide(color: typeColor),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.people,
                                size: 14, // Smaller icon
                                color: typeColor,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                "Students",
                                style: TextStyle(
                                  fontSize: 10, // Smaller text
                                  color: typeColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.more_vert,
                            size: 18, // Smaller icon
                          ),
                          color: Colors.grey[700],
                          padding: EdgeInsets.zero, // Remove padding
                          constraints: const BoxConstraints(), // Remove constraints
                          onPressed: () {
                            _showClassOptions(context, classItem, isActive);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Show class options bottom sheet
  void _showClassOptions(BuildContext context, ClassModel classItem, bool isActive) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                Icons.edit,
                color: Colors.indigo[600],
              ),
              title: const Text("Edit Class"),
              onTap: () {
                Navigator.pop(context);
                // Navigate to edit class
              },
            ),
            ListTile(
              leading: Icon(
                isActive ? Icons.pause_circle : Icons.play_circle,
                color: isActive ? Colors.orange[700] : Colors.green[600],
              ),
              title: Text(isActive ? "Deactivate Class" : "Activate Class"),
              onTap: () {
                Navigator.pop(context);
                // Toggle active status
              },
            ),
            ListTile(
              leading: Icon(
                Icons.delete,
                color: Colors.red[600],
              ),
              title: const Text("Delete Class"),
              onTap: () {
                Navigator.pop(context);
                // Delete class with confirmation
              },
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to get an appropriate icon based on class type
  IconData _getIconForClassType(String? type) {
    if (type == null) return Icons.school;

    switch (type.toLowerCase()) {
      case 'junior':
        return Icons.child_care;
      case 'senior':
        return Icons.person;
      default:
        return Icons.school;
    }
  }

  // Helper method to get color based on class type
  Color _getColorForClassType(String? type) {
    if (type == null) return Colors.indigo;

    switch (type.toLowerCase()) {
      default:
        return Colors.indigo[700]!;
    }
  }

  // Helper method to highlight search matches in text with improved styling
  TextSpan _highlightMatches(String text, String query) {
    if (query.isEmpty) {
      return TextSpan(
        text: text,
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 14, // Smaller font
          fontWeight: FontWeight.bold,
        ),
      );
    }

    final List<TextSpan> spans = [];
    final String lowercaseText = text.toLowerCase();
    final String lowercaseQuery = query.toLowerCase();

    int start = 0;
    int indexOfMatch;

    while (true) {
      indexOfMatch = lowercaseText.indexOf(lowercaseQuery, start);
      if (indexOfMatch == -1) {
        // No more matches
        if (start < text.length) {
          spans.add(
            TextSpan(
              text: text.substring(start),
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 14, // Smaller font
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }
        break;
      }

      // Add text before match
      if (indexOfMatch > start) {
        spans.add(
          TextSpan(
            text: text.substring(start, indexOfMatch),
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 14, // Smaller font
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      }

      // Add highlighted match with improved highlighting
      spans.add(
        TextSpan(
          text: text.substring(indexOfMatch, indexOfMatch + query.length),
          style: TextStyle(
            color: Colors.indigo[800],
            fontSize: 14, // Smaller font
            fontWeight: FontWeight.bold,
            backgroundColor: Colors.yellow[100],
            decoration: TextDecoration.underline,
            decorationColor: Colors.indigo[300],
          ),
        ),
      );

      // Move start to end of match for next iteration
      start = indexOfMatch + query.length;
    }

    return TextSpan(children: spans);
  }
}