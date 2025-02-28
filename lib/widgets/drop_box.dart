import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Providers/dropdown_provider.dart';

class DropDownBox extends StatelessWidget {
  final List<String> items;
  final String labelText;
  final Icon icon;
  final String dropdownKey; // Unique key for each dropdown

  const DropDownBox({
    required this.items,
    required this.labelText,
    required this.icon,
    required this.dropdownKey, // Required unique key
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<DropDownProvider>(
      builder: (context, dropDownProvider, child) {
        return DropdownButtonFormField<String>(
          dropdownColor: const Color.fromRGBO(247, 240, 238, 1),
          value: dropDownProvider.getSelectedValue(dropdownKey), // Use key to get value
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: (String? newValue) {
            dropDownProvider.setSelectedValue(dropdownKey, newValue); // Store with key
          },
          validator: (value) => value == null ? "Please select an option" : null,
          decoration: InputDecoration(
            prefixIcon: icon,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.black45),
            ),
            labelText: labelText,
          ),
        );
      },
    );
  }
}
