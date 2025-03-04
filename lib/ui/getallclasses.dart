import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:pcte_event_management/Api_Calls/class_api.dart';
import 'package:pcte_event_management/LocalStorage/Secure_Store.dart';
import '../Models/class_model.dart';


class ClassScreen extends StatefulWidget {
  @override
  _ClassScreenState createState() => _ClassScreenState();
}

class _ClassScreenState extends State<ClassScreen> {
  late Future<List<ClassModel>> _classesFuture;

  String? tkn;

  @override
  void initState() {
    super.initState();
    // Replace with the actual token

    _classesFuture = ApiService.getAllClasses();
    log(_classesFuture.toString());
  }

  Future<void> token() async
  {
    SecureStorage secureStorage = SecureStorage();
     tkn = await secureStorage.getData('jwtToken');
     log(tkn!);
  }

  @override
  Widget build(BuildContext context) {
    // State variables for search and filtering
    final TextEditingController searchController = TextEditingController();
    final ValueNotifier<String> searchQuery = ValueNotifier<String>('');
    final ValueNotifier<String> filterStatus = ValueNotifier<String>('all');

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
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
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

                  // Filter options with improved styling
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Filter by Status:",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: Colors.grey[800],

                          ),
                        ),
                        ValueListenableBuilder<String>(
                          valueListenable: filterStatus,
                          builder: (context, status, _) {
                            return SegmentedButton<String>(
                              segments: const [
                                ButtonSegment(
                                  value: 'all',
                                  label: Text('All'),
                                  icon: Icon(Icons.view_list),
                                ),
                                ButtonSegment(
                                  value: 'active',
                                  label: Text('Active'),
                                  icon: Icon(Icons.check_circle_outline),
                                ),
                                ButtonSegment(
                                  value: 'inactive',
                                  label: Text('Inactive'),
                                  icon: Icon(Icons.pause_circle_outline),
                                ),
                              ],
                              selected: {status},
                              onSelectionChanged: (Set<String> newSelection) {
                                filterStatus.value = newSelection.first;
                              },
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.resolveWith<Color>(
                                      (Set<MaterialState> states) {
                                    if (states.contains(MaterialState.selected)) {
                                      return Color(0xFF9E2A2F);
                                    }
                                    return Colors.white;
                                  },
                                ),
                                foregroundColor: MaterialStateProperty.resolveWith<Color>(
                                      (Set<MaterialState> states) {
                                    if (states.contains(MaterialState.selected)) {
                                      return Colors.white;
                                    }
                                    return Color(0xFF9E2A2F);
                                  },
                                ),
                                side: MaterialStateProperty.all(
                                  BorderSide(color: Colors.indigo[300]!, width: 1),
                                ),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                visualDensity: VisualDensity.compact,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Classes grid with improved styling
            Expanded(
              child: FutureBuilder<List<ClassModel>>(
                future: ApiService.getAllClasses(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
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
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Container(
                        width: 300,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
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
                                // Refresh action
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
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Container(
                        width: 300,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
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
                                backgroundColor:Color(0xFF9E2A2F),
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
                  } else {
                    final allClasses = snapshot.data!;

                    return ValueListenableBuilder<String>(
                      valueListenable: searchQuery,
                      builder: (context, query, _) {
                        return ValueListenableBuilder<String>(
                          valueListenable: filterStatus,
                          builder: (context, status, _) {
                            // Filter classes based on search query and status
                            final filteredClasses = allClasses.where((classItem) {
                              // First filter by status
                              if (status != 'all') {
                                final bool isActive = classItem.isActive == true;
                                if (status == 'active' && !isActive) return false;
                                if (status == 'inactive' && isActive) return false;
                              }

                              // Then filter by query
                              if (query.isEmpty) return true;
                              return classItem.name?.toLowerCase().contains(query.toLowerCase()) ?? false;
                            }).toList();

                            if (filteredClasses.isEmpty) {
                              return Center(
                                child: Container(
                                  width: 300,
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
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

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "${filteredClasses.length} ${filteredClasses.length == 1 ? 'Class' : 'Classes'}",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                          color: Colors.grey[800],
                                        ),
                                      ),
                                      PopupMenuButton<String>(
                                        icon: Icon(Icons.sort, color: Colors.indigo[700]),
                                        tooltip: 'Sort classes',
                                        itemBuilder: (context) => [
                                          const PopupMenuItem(
                                            value: 'name',
                                            child: Text('Sort by Name'),
                                          ),
                                          const PopupMenuItem(
                                            value: 'type',
                                            child: Text('Sort by Type'),
                                          ),
                                          const PopupMenuItem(
                                            value: 'recent',
                                            child: Text('Sort by Recently Added'),
                                          ),
                                        ],
                                        onSelected: (value) {
                                          // Handle sorting
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: GridView.builder(
                                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 16,
                                      mainAxisSpacing: 16,
                                      childAspectRatio: 0.85,
                                    ),
                                    itemCount: filteredClasses.length,
                                    itemBuilder: (context, index) {
                                      final classItem = filteredClasses[index];
                                      final bool isActive = classItem.isActive == true;

                                      // Get a random pastel color based on class type for visual variety
                                      final Color typeColor = _getColorForClassType(classItem.type);

                                      return GestureDetector(
                                        onTap: () {
                                          // Handle card tap - navigate to details
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(16),
                                            boxShadow: [
                                              BoxShadow(
                                                color: typeColor.withOpacity(0.2),
                                                spreadRadius: 1,
                                                blurRadius: 8,
                                                offset: const Offset(0, 3),
                                              ),
                                            ],
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              // Header with icon and status badge
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 16,
                                                  vertical: 14,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: typeColor.withOpacity(0.15),
                                                  borderRadius: const BorderRadius.only(
                                                    topLeft: Radius.circular(16),
                                                    topRight: Radius.circular(16),
                                                  ),
                                                ),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Container(
                                                      padding: const EdgeInsets.all(8),
                                                      decoration: BoxDecoration(
                                                        color: typeColor.withOpacity(0.9),
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: Icon(
                                                        _getIconForClassType(classItem.type),

                                                        color: Colors.white,
                                                        size: 20,
                                                      ),
                                                    ),
                                                    // FIXED: Status badge with flexible width instead of fixed
                                                    Container(
                                                      constraints: const BoxConstraints(minWidth: 72),
                                                      height: 28,
                                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                                      alignment: Alignment.center,
                                                      decoration: BoxDecoration(
                                                        color: isActive
                                                            ? Colors.green[600]
                                                            : Colors.red[400],
                                                        borderRadius: BorderRadius.circular(14),
                                                      ),
                                                      child: Text(
                                                        isActive ? "Active" : "Inactive",
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontWeight: FontWeight.w500,
                                                          fontSize: 12,
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
                                                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
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

                                                      const SizedBox(height: 6),

                                                      // Class type with better styling
                                                      Container(
                                                        padding: const EdgeInsets.symmetric(
                                                          horizontal: 8,
                                                          vertical: 4,
                                                        ),
                                                        decoration: BoxDecoration(
                                                          color: typeColor.withOpacity(0.1),
                                                          borderRadius: BorderRadius.circular(4),
                                                        ),
                                                        child: Text(
                                                          classItem.type ?? "General",
                                                          style: TextStyle(
                                                            color: typeColor.withOpacity(0.8),
                                                            fontSize: 12,
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
                                                                horizontal: 8,
                                                                vertical: 0,
                                                              ),
                                                              minimumSize: const Size(0, 32),
                                                              side: BorderSide(color: typeColor),
                                                              shape: RoundedRectangleBorder(
                                                                borderRadius: BorderRadius.circular(16),
                                                              ),
                                                            ),
                                                            child: Row(
                                                              mainAxisSize: MainAxisSize.min,
                                                              children: [
                                                                Icon(
                                                                  Icons.people,
                                                                  size: 16,
                                                                  color: typeColor,
                                                                ),
                                                                const SizedBox(width: 4),
                                                                Text(
                                                                  "Students",
                                                                  style: TextStyle(
                                                                    fontSize: 12,
                                                                    color: typeColor,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          IconButton(
                                                            icon: const Icon(
                                                              Icons.more_vert,
                                                              size: 20,
                                                            ),
                                                            color: Colors.grey[700],
                                                            onPressed: () {
                                                              // Show options menu
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

// Helper method to get an appropriate icon based on class type
  IconData _getIconForClassType(String? type) {
    if (type == null) return Icons.school;

    switch (type.toLowerCase()) {
      case "science":
        return Icons.science;
      case "math":
        return Icons.calculate;
      case "language":
        return Icons.translate;
      case "history":
        return Icons.history_edu;
      case "art":
        return Icons.palette;
      case "music":
        return Icons.music_note;
      case "physical":
        return Icons.fitness_center;
      default:
        return Icons.school;
    }
  }

// Helper method to get color based on class type
  Color _getColorForClassType(String? type) {
    if (type == null) return Colors.indigo;

    switch (type.toLowerCase()) {
      case "science":
        return Colors.blue[700]!;
      case "math":
        return Colors.purple[700]!;
      case "language":
        return Colors.teal[700]!;
      case "history":
        return Colors.brown[600]!;
      case "art":
        return Colors.pink[600]!;
      case "music":
        return Colors.deepOrange[600]!;
      case "physical":
        return Colors.green[700]!;
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
          fontSize: 16,
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
                fontSize: 16,
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
              fontSize: 16,
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
            fontSize: 16,
            fontWeight: FontWeight.bold,
            backgroundColor: Colors.yellow[100],
          ),
        ),
      );

      // Move start index to end of match
      start = indexOfMatch + query.length;
    }

    return TextSpan(children: spans);
  }

}
