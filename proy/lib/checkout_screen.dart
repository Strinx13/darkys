import 'package:flutter/material.dart';

class CheckoutScreen extends StatefulWidget {
  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String selectedPaymentMethod = 'card';
  final TextEditingController cardNumberController = TextEditingController(text: '1234 1257 1681 1578');
  final TextEditingController cardHolderController = TextEditingController(text: 'John Smith');
  final TextEditingController expiryDateController = TextEditingController(text: '05/24');
  final TextEditingController cvvController = TextEditingController(text: '***');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Checkout',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select payment method',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
            SizedBox(height: 20),
            // Métodos de pago
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _buildPaymentOption(
                  'card',
                  '',  // No usamos imagen para la tarjeta
                  Icons.credit_card,
                  isSelected: selectedPaymentMethod == 'card',
                ),
                SizedBox(width: 12),
                _buildPaymentOption(
                  'paypal',
                  'assets/paypal.png',
                  Icons.payment,
                  isSelected: selectedPaymentMethod == 'paypal',
                ),
                SizedBox(width: 12),
                _buildPaymentOption(
                  'applepay',
                  'assets/applepay.png',
                  Icons.apple,
                  isSelected: selectedPaymentMethod == 'applepay',
                ),
              ],
            ),
            SizedBox(height: 40),
            Text(
              'Cards',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            // Tarjeta de crédito
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(20),
              ),
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset(
                        'assets/chip.png',
                        height: 40,
                      ),
                      Image.asset(
                        'assets/mastercard.png',
                        height: 30,
                      ),
                    ],
                  ),
                  Text(
                    '**** **** **** 1578',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      letterSpacing: 2,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'John Smith',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '05/24',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
            // Detalles de la tarjeta
            _buildTextField('Card number', cardNumberController),
            SizedBox(height: 15),
            _buildTextField('Cardholder name', cardHolderController),
            SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: _buildTextField('Expire date', expiryDateController),
                ),
                SizedBox(width: 15),
                Expanded(
                  child: _buildTextField('CVV', cvvController, isPassword: true),
                ),
              ],
            ),
            SizedBox(height: 40),
            // Botón de pago
            Container(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Implementar lógica de pago
                },
                child: Text(
                  'Pay',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption(
    String method,
    String imagePath,
    IconData fallbackIcon, {
    bool isSelected = false,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPaymentMethod = method;
        });
      },
      child: Container(
        width: method == 'card' ? 70 : 100,
        height: 45,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.red : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(8),
          child: method == 'card'
              ? Icon(Icons.credit_card_outlined, 
                  color: isSelected ? Colors.red : Colors.grey[600],
                  size: 24)
              : Image.asset(
                  imagePath,
                  fit: BoxFit.contain,
                ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool isPassword = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isPassword,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(
                color: Colors.grey[300]!,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(
                color: Colors.grey[300]!,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(
                color: Colors.black,
                width: 1,
              ),
            ),
          ),
        ),
      ],
    );
  }
} 