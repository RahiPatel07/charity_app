import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_theme.dart';
import 'success_page.dart';

class DonationPage extends StatefulWidget {
  final String causeTitle;

  const DonationPage({super.key, required this.causeTitle});

  @override
  State<DonationPage> createState() => _DonationPageState();
}

class _DonationPageState extends State<DonationPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  bool isSubmitting = false;
  bool isAnonymous = false;
  String selectedPaymentMethod = 'card';

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    final phoneRegex = RegExp(r'^\d{10}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Enter a valid 10-digit phone number';
    }
    return null;
  }

  Future<void> submitDonation() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isSubmitting = true);

    try {
      // Simulate payment processing
      await Future.delayed(const Duration(seconds: 2));

      await FirebaseFirestore.instance.collection('donations').add({
        'name': isAnonymous ? 'Anonymous' : _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'amount': double.parse(_amountController.text.trim()),
        'cause': widget.causeTitle,
        'isAnonymous': isAnonymous,
        'paymentMethod': selectedPaymentMethod,
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SuccessPage(
            name: isAnonymous ? 'Anonymous' : _nameController.text.trim(),
            amount: _amountController.text.trim(),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Donation failed: $e'),
          backgroundColor: AppColors.error,
        ),
      );
      setState(() => isSubmitting = false);
    }
  }

  Widget _buildPaymentMethodSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Method',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppColors.text,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: AppDecorations.cardDecoration,
          child: Column(
            children: [
              RadioListTile<String>(
                title: const Row(
                  children: [
                    Icon(Icons.credit_card, color: AppColors.primary),
                    SizedBox(width: 12),
                    Text('Credit/Debit Card'),
                  ],
                ),
                value: 'card',
                groupValue: selectedPaymentMethod,
                onChanged: (value) => setState(() => selectedPaymentMethod = value!),
              ),
              RadioListTile<String>(
                title: const Row(
                  children: [
                    Icon(Icons.account_balance, color: AppColors.primary),
                    SizedBox(width: 12),
                    Text('Net Banking'),
                  ],
                ),
                value: 'netbanking',
                groupValue: selectedPaymentMethod,
                onChanged: (value) => setState(() => selectedPaymentMethod = value!),
              ),
              RadioListTile<String>(
                title: const Row(
                  children: [
                    Icon(Icons.phone_android, color: AppColors.primary),
                    SizedBox(width: 12),
                    Text('UPI'),
                  ],
                ),
                value: 'upi',
                groupValue: selectedPaymentMethod,
                onChanged: (value) => setState(() => selectedPaymentMethod = value!),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Donate to ${widget.causeTitle}'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Donation Amount Section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: AppDecorations.cardDecoration,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Donation Amount',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.text,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _amountController,
                        decoration: const InputDecoration(
                          labelText: 'Amount (₹)',
                          prefixIcon: Icon(Icons.currency_rupee),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (val) {
                          if (val == null || val.isEmpty) return 'Enter an amount';
                          final amount = int.tryParse(val);
                          if (amount == null || amount <= 0) {
                            return 'Enter a valid amount';
                          }
                          if (amount < 10) {
                            return 'Minimum donation amount is ₹10';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        children: [100, 500, 1000, 5000].map((amount) {
                          return ActionChip(
                            label: Text('₹$amount'),
                            onPressed: () {
                              _amountController.text = amount.toString();
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Personal Information Section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: AppDecorations.cardDecoration,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Personal Information',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppColors.text,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Switch(
                            value: isAnonymous,
                            onChanged: (value) => setState(() => isAnonymous = value),
                            activeColor: AppColors.primary,
                          ),
                        ],
                      ),
                      if (isAnonymous)
                        const Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Text(
                            'Your donation will be anonymous',
                            style: TextStyle(
                              color: AppColors.textLight,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nameController,
                        enabled: !isAnonymous && !isSubmitting,
                        decoration: const InputDecoration(
                          labelText: 'Full Name',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: (val) => !isAnonymous && (val == null || val.isEmpty)
                            ? 'Enter your name'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        enabled: !isSubmitting,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: validateEmail,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _phoneController,
                        enabled: !isSubmitting,
                        decoration: const InputDecoration(
                          labelText: 'Phone Number',
                          prefixIcon: Icon(Icons.phone_outlined),
                        ),
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                        validator: validatePhone,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Payment Method Section
                _buildPaymentMethodSelector(),
                const SizedBox(height: 24),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isSubmitting ? null : submitDonation,
                    child: isSubmitting
                        ? const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              ),
                              SizedBox(width: 12),
                              Text("Processing..."),
                            ],
                          )
                        : const Text("Complete Donation"),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
