import 'package:flutter/material.dart';

void main() => runApp(AtvmApp());

class AtvmApp extends StatefulWidget {
  @override
  _AtvmAppState createState() => _AtvmAppState();
}

class _AtvmAppState extends State<AtvmApp> {
  int _selectedIndex = 0;
  double _balance = 100.0;
  List<Map<String, dynamic>> _tickets = [];

  final List<String> _stations = [
    "CSMT",
    "Dadar",
    "Kurla",
    "Thane",
    "Kalyan",
    "Vashi",
    "Panvel",
    "Andheri",
    "Borivali",
    "Virar"
  ];

  String? _fromStation;
  String? _toStation;
  int _ticketCount = 1;
  bool _returnTicket = false;

  void _bookTicket(String from, String to, int count, bool isReturn) {
    int fromIndex = _stations.indexOf(from);
    int toIndex = _stations.indexOf(to);
    int distance = (toIndex - fromIndex).abs();
    if (distance == 0) distance = 1;

    double fare = distance * 5.0 * count;
    if (isReturn) fare *= 1.8;

    if (_balance >= fare) {
      setState(() {
        _balance -= fare;
        _tickets.add({
          "from": from,
          "to": to,
          "count": count,
          "return": isReturn,
          "fare": fare,
          "time": DateTime.now(),
        });
      });
      _showTicketDialog(from, to, count, isReturn, fare);
    } else {
      _showDialog("⚠️ Error", "Insufficient balance. Please recharge.");
    }
  }

  void _recharge(double amount) {
    setState(() {
      _balance += amount;
    });
    _showDialog("Recharge Successful", "Your new balance is ₹$_balance");
  }

  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            child: Text("OK"),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
    );
  }

  void _showTicketDialog(String from, String to, int count, bool isReturn, double fare) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("🎫 Mumbai Local Ticket",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Divider(),
              Text("From: $from", style: TextStyle(fontSize: 16)),
              Text("To: $to", style: TextStyle(fontSize: 16)),
              Text("Tickets: $count", style: TextStyle(fontSize: 16)),
              Text("Type: ${isReturn ? "Return" : "Single"}",
                  style: TextStyle(fontSize: 16)),
              Text("Fare: ₹$fare", style: TextStyle(fontSize: 16)),
              SizedBox(height: 16),
              Container(
                height: 100,
                width: 100,
                color: Colors.grey.shade300,
                child: Center(child: Text("QR")),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                child: Text("Close"),
                onPressed: () => Navigator.pop(context),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _ticketBookingPage() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<String>(
            decoration: InputDecoration(labelText: "From Station"),
            items: _stations
                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                .toList(),
            value: _fromStation,
            onChanged: (v) => setState(() => _fromStation = v),
          ),
          SizedBox(height: 10),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(labelText: "To Station"),
            items: _stations
                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                .toList(),
            value: _toStation,
            onChanged: (v) => setState(() => _toStation = v),
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Text("Tickets: "),
              IconButton(
                icon: Icon(Icons.remove),
                onPressed: _ticketCount > 1
                    ? () => setState(() => _ticketCount--)
                    : null,
              ),
              Text("$_ticketCount"),
              IconButton(
                icon: Icon(Icons.add),
                onPressed: () => setState(() => _ticketCount++),
              ),
            ],
          ),
          Row(
            children: [
              Checkbox(
                  value: _returnTicket,
                  onChanged: (v) => setState(() => _returnTicket = v!)),
              Text("Return Ticket"),
            ],
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _fromStation != null && _toStation != null
                ? () => _bookTicket(
                    _fromStation!, _toStation!, _ticketCount, _returnTicket)
                : null,
            child: Text("Book Ticket"),
          )
        ],
      ),
    );
  }

  Widget _rechargePage() {
    TextEditingController _controller = TextEditingController();
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Text("Current Balance: ₹$_balance",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 20),
          TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: "Enter recharge amount",
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            child: Text("Recharge"),
            onPressed: () {
              double? amount = double.tryParse(_controller.text);
              if (amount != null && amount > 0) {
                _recharge(amount);
              } else {
                _showDialog("Error", "Enter a valid amount.");
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _historyPage() {
    return ListView.builder(
      itemCount: _tickets.length,
      itemBuilder: (_, i) {
        final t = _tickets[i];
        return Card(
          margin: EdgeInsets.all(8),
          child: ListTile(
            leading: Icon(Icons.train, color: Colors.green),
            title: Text("${t['from']} → ${t['to']}"),
            subtitle: Text(
                "Count: ${t['count']}, Type: ${t['return'] ? "Return" : "Single"}\nFare: ₹${t['fare']}"),
            trailing: Text(
              "${t['time'].hour}:${t['time'].minute.toString().padLeft(2, '0')}",
              style: TextStyle(fontSize: 12),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _pages = [_ticketBookingPage(), _rechargePage(), _historyPage()];

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Mumbai ATVM",
      home: Scaffold(
        appBar: AppBar(
          title: Text("Mumbai ATVM"),
          backgroundColor: Colors.green.shade700,
        ),
        body: _pages[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.train), label: "Book"),
            BottomNavigationBarItem(icon: Icon(Icons.credit_card), label: "Recharge"),
            BottomNavigationBarItem(icon: Icon(Icons.history), label: "History"),
          ],
          onTap: (index) => setState(() => _selectedIndex = index),
        ),
      ),
    );
  }
}

// Ammar Kaskar's Project
