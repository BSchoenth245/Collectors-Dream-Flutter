import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'login.dart';

void main() {
  runApp(CollectorsDreamApp());
}

class CollectorsDreamApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Collector\'s Dream',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        primaryColor: Color(0xFF7c3aed),
        hoverColor: Color(0xFF6d28d9),
        cardColor: Colors.white,
        scaffoldBackgroundColor: Color(0xFFf1f5f9),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF7c3aed),
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF7c3aed),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(color: Color(0xFF7c3aed)),
          ),
        ),
      ),
      home: AuthenticationScreen(),
      routes: {
        '/home': (context) => DataTableScreen(),
      },
    );
  }
}

class DataTableScreen extends StatefulWidget {
  @override
  _DataTableScreenState createState() => _DataTableScreenState();
}

class _DataTableScreenState extends State<DataTableScreen> {
  List<Map<String, dynamic>> tableData = [];
  List<Map<String, dynamic>> filteredData = [];
  Map<String, dynamic> categories = {};
  String selectedCategory = '';
  bool isLoading = true;
  String searchQuery = '';
  int itemsPerPage = 25;
  int currentPage = 0;
  List<String> allColumns = [];

  // Mock data for demonstration (replace with your API calls)
  final List<Map<String, dynamic>> mockData = [
    {
      '_id': '1',
      'category': 'books',
      'title': 'The Great Gatsby',
      'author': 'F. Scott Fitzgerald',
      'year': 1925,
      'condition': 'Excellent',
      'owned': true,
      'price': 15.99,
    },
    {
      '_id': '2',
      'category': 'books',
      'title': '1984',
      'author': 'George Orwell',
      'year': 1949,
      'condition': 'Good',
      'owned': true,
      'price': 12.50,
    },
    {
      '_id': '3',
      'category': 'coins',
      'name': 'Morgan Silver Dollar',
      'year': 1885,
      'mint_mark': 'S',
      'grade': 'MS-63',
      'value': 125.00,
      'owned': false,
    },
    {
      '_id': '4',
      'category': 'books',
      'title': 'To Kill a Mockingbird',
      'author': 'Harper Lee',
      'year': 1960,
      'condition': 'Fair',
      'owned': true,
      'price': 8.99,
    },
    {
      '_id': '5',
      'category': 'coins',
      'name': 'Walking Liberty Half Dollar',
      'year': 1943,
      'mint_mark': 'D',
      'grade': 'VF-20',
      'value': 45.00,
      'owned': true,
    },
  ];

  final Map<String, dynamic> mockCategories = {
    'books': {
      'name': 'Books',
      'fields': [
        {'name': 'title', 'label': 'Title', 'type': 'text'},
        {'name': 'author', 'label': 'Author', 'type': 'text'},
        {'name': 'year', 'label': 'Year', 'type': 'number'},
        {'name': 'condition', 'label': 'Condition', 'type': 'text'},
        {'name': 'owned', 'label': 'Owned', 'type': 'boolean'},
        {'name': 'price', 'label': 'Price', 'type': 'number'},
      ]
    },
    'coins': {
      'name': 'Coins',
      'fields': [
        {'name': 'name', 'label': 'Coin Name', 'type': 'text'},
        {'name': 'year', 'label': 'Year', 'type': 'number'},
        {'name': 'mint_mark', 'label': 'Mint Mark', 'type': 'text'},
        {'name': 'grade', 'label': 'Grade', 'type': 'text'},
        {'name': 'value', 'label': 'Value', 'type': 'number'},
        {'name': 'owned', 'label': 'Owned', 'type': 'boolean'},
      ]
    },
  };

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    setState(() {
      isLoading = true;
    });

    try {
      // TODO: Replace with actual API calls
      // final response = await http.get(Uri.parse('http://127.0.0.1:8000/api/collection'));
      // final categoriesResponse = await http.get(Uri.parse('http://127.0.0.1:8000/api/categories'));
      
      // Mock delay to simulate API call
      await Future.delayed(Duration(milliseconds: 500));
      
      setState(() {
        tableData = List<Map<String, dynamic>>.from(mockData);
        categories = Map<String, dynamic>.from(mockCategories);
        filteredData = List<Map<String, dynamic>>.from(tableData);
        _updateColumns();
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _updateColumns() {
    Set<String> columnSet = {};
    for (var item in filteredData) {
      item.keys.forEach((key) {
        if (key != '_id' && key != '__v' && key != 'category') {
          columnSet.add(key);
        }
      });
    }
    allColumns = columnSet.toList()..sort();
  }

  void filterByCategory(String? categoryKey) {
    setState(() {
      selectedCategory = categoryKey ?? '';
      if (selectedCategory.isEmpty) {
        filteredData = List<Map<String, dynamic>>.from(tableData);
      } else {
        filteredData = tableData.where((item) => 
          item['category'] == selectedCategory).toList();
      }
      _updateColumns();
      currentPage = 0;
    });
  }

  void searchData(String query) {
    setState(() {
      searchQuery = query.toLowerCase();
      if (selectedCategory.isEmpty) {
        filteredData = tableData.where((item) {
          return item.values.any((value) => 
            value.toString().toLowerCase().contains(searchQuery));
        }).toList();
      } else {
        filteredData = tableData.where((item) {
          bool categoryMatch = item['category'] == selectedCategory;
          bool searchMatch = item.values.any((value) => 
            value.toString().toLowerCase().contains(searchQuery));
          return categoryMatch && searchMatch;
        }).toList();
      }
      _updateColumns();
      currentPage = 0;
    });
  }

  List<Map<String, dynamic>> getCurrentPageData() {
    final startIndex = currentPage * itemsPerPage;
    final endIndex = (startIndex + itemsPerPage).clamp(0, filteredData.length);
    return filteredData.sublist(startIndex, endIndex);
  }

  int get totalPages => (filteredData.length / itemsPerPage).ceil();

  void editRecord(String id) {
    final record = filteredData.firstWhere((item) => item['_id'] == id);
    showDialog(
      context: context,
      builder: (context) => EditRecordDialog(
        record: record,
        categories: categories,
        onSave: (updatedRecord) {
          // TODO: API call to update record
          setState(() {
            final index = tableData.indexWhere((item) => item['_id'] == id);
            if (index != -1) {
              tableData[index] = {...tableData[index], ...updatedRecord};
              filterByCategory(selectedCategory.isEmpty ? null : selectedCategory);
            }
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Record updated successfully!')),
          );
        },
      ),
    );
  }

  void deleteRecord(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Record'),
        content: Text('Are you sure you want to delete this record?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: API call to delete record
              setState(() {
                tableData.removeWhere((item) => item['_id'] == id);
                filterByCategory(selectedCategory.isEmpty ? null : selectedCategory);
              });
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Record deleted successfully!')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Collector\'s Dream - Search Entries'),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFf1f5f9), Color(0xFFe2e8f0)],
          ),
        ),
        child: RefreshIndicator(
          onRefresh: loadData,
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height,
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search and Filter Controls
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Select Category:', 
                        style: TextStyle(fontWeight: FontWeight.w500)),
                      SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: selectedCategory.isEmpty ? null : selectedCategory,
                        decoration: InputDecoration(
                          hintText: 'Choose a category...',
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: [
                          DropdownMenuItem<String>(
                            value: null,
                            child: Text('All Categories'),
                          ),
                          ...categories.entries.map((entry) => 
                            DropdownMenuItem<String>(
                              value: entry.key,
                              child: Text(entry.value['name']),
                            ),
                          ),
                        ],
                        onChanged: filterByCategory,
                      ),
                      SizedBox(height: 16),
                      Text('Search:', 
                        style: TextStyle(fontWeight: FontWeight.w500)),
                      SizedBox(height: 8),
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'Search records...',
                          prefixIcon: Icon(Icons.search),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        onChanged: searchData,
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 24),
                  
                  // Data Table Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Database Records',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${filteredData.length} records',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 16),
                  
                  // Data Table
                  Container(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: isLoading
                        ? Center(child: CircularProgressIndicator())
                        : filteredData.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
                                    SizedBox(height: 16),
                                    Text(
                                      'No records found',
                                      style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                              )
                            : Column(
                                children: [
                                  Expanded(
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: DataTable(
                                        headingRowColor: MaterialStateProperty.all(Colors.grey[100]),
                                        columns: [
                                          ...allColumns.map((column) => DataColumn(
                                            label: Text(
                                              column.split('_').map((word) => 
                                                word.isEmpty ? '' : 
                                                word[0].toUpperCase() + word.substring(1)
                                              ).join(' '),
                                              style: TextStyle(fontWeight: FontWeight.bold),
                                            ),
                                          )),
                                          DataColumn(
                                            label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold)),
                                            numeric: false,
                                          ),
                                        ],
                                        rows: getCurrentPageData().map((item) {
                                          return DataRow(
                                            cells: [
                                              ...allColumns.map((column) {
                                                final value = item[column];
                                                String displayValue;
                                                if (value is bool) {
                                                  displayValue = value ? 'Yes' : 'No';
                                                } else if (value == null) {
                                                  displayValue = 'N/A';
                                                } else {
                                                  displayValue = value.toString();
                                                }
                                                return DataCell(Text(displayValue));
                                              }),
                                              DataCell(
                                                Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    ElevatedButton(
                                                      onPressed: () => editRecord(item['_id']),
                                                      child: Text('Edit', style: TextStyle(fontSize: 12)),
                                                      style: ElevatedButton.styleFrom(
                                                        minimumSize: Size(60, 28),
                                                        padding: EdgeInsets.symmetric(horizontal: 8),
                                                      ),
                                                    ),
                                                    SizedBox(width: 4),
                                                    ElevatedButton(
                                                      onPressed: () => deleteRecord(item['_id']),
                                                      child: Text('Delete', style: TextStyle(fontSize: 12)),
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor: Colors.red,
                                                        minimumSize: Size(60, 28),
                                                        padding: EdgeInsets.symmetric(horizontal: 8),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ),
                                  
                                  // Pagination Controls
                                  if (totalPages > 1) ...[
                                    SizedBox(height: 16),
                                    Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text('Items per page: '),
                                            DropdownButton<int>(
                                              value: itemsPerPage,
                                              items: [10, 25, 50, 100].map((int value) {
                                                return DropdownMenuItem<int>(
                                                  value: value,
                                                  child: Text(value.toString()),
                                                );
                                              }).toList(),
                                              onChanged: (int? newValue) {
                                                setState(() {
                                                  itemsPerPage = newValue!;
                                                  currentPage = 0;
                                                });
                                              },
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            IconButton(
                                              onPressed: currentPage > 0 
                                                ? () => setState(() => currentPage--)
                                                : null,
                                              icon: Icon(Icons.chevron_left),
                                            ),
                                            Text('${currentPage + 1} of $totalPages'),
                                            IconButton(
                                              onPressed: currentPage < totalPages - 1
                                                ? () => setState(() => currentPage++)
                                                : null,
                                              icon: Icon(Icons.chevron_right),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  ),
  ),
    );
  }
}

class EditRecordDialog extends StatefulWidget {
  final Map<String, dynamic> record;
  final Map<String, dynamic> categories;
  final Function(Map<String, dynamic>) onSave;

  const EditRecordDialog({
    Key? key,
    required this.record,
    required this.categories,
    required this.onSave,
  }) : super(key: key);

  @override
  _EditRecordDialogState createState() => _EditRecordDialogState();
}

class _EditRecordDialogState extends State<EditRecordDialog> {
  final _formKey = GlobalKey<FormState>();
  late Map<String, dynamic> editedRecord;

  @override
  void initState() {
    super.initState();
    editedRecord = Map<String, dynamic>.from(widget.record);
  }

  @override
  Widget build(BuildContext context) {
    final category = widget.categories[widget.record['category']];
    final categoryName = category != null ? category['name'] : 'Item';
    
    return Dialog(
      child: Container(
        width: 500,
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Edit $categoryName',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            
            Form(
              key: _formKey,
              child: Container(
                constraints: BoxConstraints(maxHeight: 400),
                child: SingleChildScrollView(
                  child: Column(
                    children: editedRecord.keys
                        .where((key) => key != '_id' && key != '__v' && key != 'category')
                        .map((fieldName) {
                      final currentValue = editedRecord[fieldName];
                      
                      if (currentValue is bool) {
                        return CheckboxListTile(
                          title: Text(fieldName.split('_').map((word) => 
                            word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1)
                          ).join(' ')),
                          value: currentValue,
                          onChanged: (bool? value) {
                            setState(() {
                              editedRecord[fieldName] = value ?? false;
                            });
                          },
                        );
                      } else {
                        return Padding(
                          padding: EdgeInsets.only(bottom: 16),
                          child: TextFormField(
                            initialValue: currentValue?.toString() ?? '',
                            decoration: InputDecoration(
                              labelText: fieldName.split('_').map((word) => 
                                word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1)
                              ).join(' '),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'This field is required';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              if (currentValue is num) {
                                editedRecord[fieldName] = double.tryParse(value!) ?? 0;
                              } else {
                                editedRecord[fieldName] = value;
                              }
                            },
                          ),
                        );
                      }
                    }).toList(),
                  ),
                ),
              ),
            ),
            
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cancel'),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      widget.onSave(editedRecord);
                      Navigator.of(context).pop();
                    }
                  },
                  child: Text('Save Changes'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}