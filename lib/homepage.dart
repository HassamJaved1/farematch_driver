import 'package:farematch_driver/global.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
// For associateMethods, userName, userPhone
import 'loginpage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _rideRequestsRef =
      FirebaseDatabase.instance.ref().child("rideRequests");

  Future<void> _logout(BuildContext context) async {
    try {
      await _auth.signOut();
      associateMethods.showSnackBarMsg("Logged out successfully", context);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } catch (e) {
      associateMethods.showSnackBarMsg("Error logging out: $e", context);
    }
  }

  // Accept a ride request
  void _acceptRide(String rideId, Map rideData) async {
    try {
      String driverId = _auth.currentUser!.uid;
      await _rideRequestsRef.child(rideId).update({
        "status": "accepted",
        "driverId": driverId,
      });
      associateMethods.showSnackBarMsg("Ride accepted successfully", context);
      // TODO: Navigate to a screen with directions using Google Maps
      // Example: Navigator.push(context, MaterialPageRoute(builder: (context) => RideNavigationScreen(rideData: rideData)));
    } catch (e) {
      associateMethods.showSnackBarMsg("Error accepting ride: $e", context);
    }
  }

  // Reject a ride request
  void _rejectRide(String rideId) async {
    try {
      await _rideRequestsRef.child(rideId).update({
        "status": "rejected",
        "driverId": _auth.currentUser!.uid,
      });
      associateMethods.showSnackBarMsg("Ride rejected", context);
    } catch (e) {
      associateMethods.showSnackBarMsg("Error rejecting ride: $e", context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Dashboard'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => _logout(context),
            tooltip: 'Log Out',
          ),
        ],
      ),
      body: Column(
        children: [
          // Welcome Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, $userName!',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    // TODO: Navigate to Earnings Screen
                    associateMethods.showSnackBarMsg(
                        "Earnings feature coming soon!", context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                  ),
                  child: const Text(
                    "View Earnings",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          // Ride Requests Section
          Expanded(
            child: StreamBuilder(
              stream: _rideRequestsRef.onValue,
              builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }
                if (!snapshot.hasData ||
                    snapshot.data!.snapshot.value == null) {
                  return const Center(
                      child: Text("No ride requests available"));
                }

                // Parse ride requests
                Map<dynamic, dynamic> rideRequests =
                    snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                List<MapEntry<dynamic, dynamic>> rideList = rideRequests.entries
                    .where((entry) =>
                        entry.value["status"] == "pending" &&
                        (entry.value["driverId"] == null ||
                            entry.value["driverId"] == ""))
                    .toList();

                if (rideList.isEmpty) {
                  return const Center(child: Text("No pending ride requests"));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: rideList.length,
                  itemBuilder: (context, index) {
                    var ride = rideList[index];
                    String rideId = ride.key;
                    Map rideData = ride.value;

                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Rider: ${rideData['riderName']}",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text("Pickup: ${rideData['pickupLocation']}"),
                            Text("Dropoff: ${rideData['dropoffLocation']}"),
                            Text(
                                "Fare: \$${rideData['fare'].toStringAsFixed(2)}"),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton(
                                  onPressed: () =>
                                      _acceptRide(rideId, rideData),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.teal,
                                  ),
                                  child: const Text(
                                    "Accept",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                OutlinedButton(
                                  onPressed: () => _rejectRide(rideId),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: Colors.red),
                                  ),
                                  child: const Text(
                                    "Reject",
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
