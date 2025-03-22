import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class MedicalReportsPage extends StatefulWidget {
  final String hid; // Declare the property

  const MedicalReportsPage({Key? key, required this.hid}) : super(key: key);

  @override
  _MedicalReportsPageState createState() => _MedicalReportsPageState();
}

class _MedicalReportsPageState extends State<MedicalReportsPage>
    with SingleTickerProviderStateMixin {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  List<Map<String, dynamic>> _medicalRecords = [];
  bool _isLoading = true;
  late AnimationController _animationController;
  String? _error;

  // For PDF viewing
  bool _isPdfLoading = false;
  String? _pdfPath;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _fetchMedicalRecords();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _fetchMedicalRecords() async {
    try {
      'hid'; // Use current user ID or fallback to 'hid'

      final DatabaseReference recordsRef =
          _database.ref().child('user/${widget.hid}/patientRecords');
      final DataSnapshot snapshot = await recordsRef.get();

      setState(() {
        _isLoading = false;
        _error = null;
        _medicalRecords = [];
      });

      if (snapshot.exists && snapshot.value != null) {
        final data = snapshot.value as Map<dynamic, dynamic>;

        data.forEach((recordId, recordData) {
          if (recordData is Map<dynamic, dynamic>) {
            _medicalRecords.add({
              'id': recordId,
              ...Map<String, dynamic>.from(recordData),
            });
          }
        });

        // Sort by appointment date (newest first)
        _medicalRecords.sort((a, b) {
          final aDate = a['appointmentDate'] as String? ?? '';
          final bDate = b['appointmentDate'] as String? ?? '';
          return bDate.compareTo(aDate);
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Error fetching medical records: $e';
      });
    }
  }

  Future<void> _downloadAndOpenPdf(String fileUrl) async {
    try {
      setState(() {
        _isPdfLoading = true;
      });

      // Download the PDF
      final http.Response response = await http.get(Uri.parse(fileUrl));

      // Get temporary directory
      final Directory tempDir = await getTemporaryDirectory();
      final String tempPath = '${tempDir.path}/temp_medical_report.pdf';

      // Write PDF to file
      final File file = File(tempPath);
      await file.writeAsBytes(response.bodyBytes);

      setState(() {
        _pdfPath = tempPath;
        _isPdfLoading = false;
      });

      // Show PDF viewer
      _showPdfViewer();
    } catch (e) {
      setState(() {
        _isPdfLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load PDF: $e')),
      );
    }
  }

  void _showPdfViewer() {
    if (_pdfPath == null) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text(
              'Medical Report',
              style: TextStyle(color: Colors.white),
            ),
            iconTheme: IconThemeData(color: Colors.white),
            backgroundColor: Colors.indigo,
          ),
          body: PDFView(
            filePath: _pdfPath!,
            enableSwipe: true,
            swipeHorizontal: true,
            autoSpacing: false,
            pageFling: false,
            pageSnap: true,
            defaultPage: 0,
            fitPolicy: FitPolicy.BOTH,
            preventLinkNavigation: false,
            onError: (error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error loading PDF: $error')),
              );
            },
            onPageError: (page, error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error on page $page: $error')),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: const Text(
          'Medical Reports',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.indigo,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchMedicalRecords,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SpinKitDoubleBounce(
              color: Colors.blueAccent,
              size: 60.0,
              controller: _animationController,
            ),
            const SizedBox(height: 20),
            const Text(
              'Loading your medical history...',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 60,
              color: Colors.redAccent,
            ),
            const SizedBox(height: 20),
            Text(
              _error!,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _fetchMedicalRecords,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.black,
              ),
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (_medicalRecords.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/no_records.png', // Make sure to add this asset
              width: 150,
              height: 150,
              color: Colors.white30,
            ),
            const SizedBox(height: 20),
            const Text(
              'No medical records found',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Your health records will appear here',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        ListView.builder(
          padding: const EdgeInsets.only(top: 16, bottom: 80),
          itemCount: _medicalRecords.length,
          itemBuilder: (context, index) {
            final record = _medicalRecords[index];
            final appointmentDate =
                record['appointmentDate'] as String? ?? 'Unknown Date';
            final formattedDate = _formatDate(appointmentDate);
            final doctorName =
                record['doctorname'] as String? ?? 'Unknown Doctor';
            final diagnosis = record['diagnosis'] as String? ?? 'No diagnosis';
            final bp = record['bp'] as String? ?? 'N/A';
            final heartRate = record['heartRate'] as String? ?? 'N/A';
            final sugarLevel = record['sugarLevel'] as String? ?? 'N/A';
            final fileUrl = record['fileUrl'] as String? ?? '';
            final prescription =
                record['prescription'] as String? ?? 'No prescription';
            final recordId = record['id'] as String? ?? '';

            // Handle summary data which might be in JSON format
            String? patientAge;
            String? patientGender;
            try {
              if (record['summary'] is String) {
                final summaryStr = record['summary'] as String? ?? '';
                if (summaryStr.contains('patient_information')) {
                  // Attempt to parse JSON-like string
                  // This is a simplified approach and may need adjustment
                  final agePattern = RegExp(r'"age"\s*:\s*"([^"]+)"');
                  final ageMatch = agePattern.firstMatch(summaryStr);
                  if (ageMatch != null && ageMatch.groupCount >= 1) {
                    patientAge = ageMatch.group(1);
                  }

                  final genderPattern = RegExp(r'"gender"\s*:\s*"([^"]+)"');
                  final genderMatch = genderPattern.firstMatch(summaryStr);
                  if (genderMatch != null && genderMatch.groupCount >= 1) {
                    patientGender = genderMatch.group(1);
                  }
                }
              }
            } catch (e) {
              // Ignore parsing errors
            }

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: const Color.fromARGB(176, 44, 55, 118),
              child: ExpansionTile(
                tilePadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                childrenPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                expandedCrossAxisAlignment: CrossAxisAlignment.start,
                title: Text(
                  formattedDate,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      'Added by Dr. $doctorName',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      diagnosis,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                trailing: CircleAvatar(
                  radius: 16,
                  backgroundColor:
                      _getHealthIndicatorColor(bp, heartRate, sugarLevel),
                  child: const Icon(
                    Icons.favorite,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                children: [
                  const Divider(color: Colors.white24),
                  const SizedBox(height: 8),

                  // Vital signs section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildVitalSign('BP', bp, Icons.favorite_border),
                      _buildVitalSign('Heart Rate', heartRate,
                          Icons.monitor_heart_outlined),
                      _buildVitalSign(
                          'Sugar', sugarLevel, Icons.water_drop_outlined),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Patient info
                  if (patientAge != null || patientGender != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        children: [
                          const Icon(Icons.person_outline,
                              color: Colors.white54, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Patient: ${[
                              if (patientAge != null) patientAge,
                              if (patientGender != null) patientGender,
                            ].join(', ')}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Diagnosis
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.medical_information_outlined,
                          color: Colors.white54, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Diagnosis:',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              diagnosis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Prescription
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.medication_outlined,
                          color: Colors.white54, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Prescription:',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              prescription,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // View file button
                  if (fileUrl.isNotEmpty)
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: () => _downloadAndOpenPdf(fileUrl),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        icon: const Icon(Icons.file_open),
                        label: const Text(
                          'View Medical Report',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
        if (_isPdfLoading)
          Container(
            color: Colors.white.withOpacity(0.7),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SpinKitPulsingGrid(
                    color: Colors.blueAccent,
                    size: 50.0,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Loading medical report...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildVitalSign(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white54, size: 18),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final DateTime date = DateTime.parse(dateStr);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  Color _getHealthIndicatorColor(
      String bp, String heartRate, String sugarLevel) {
    // Simple algorithm to determine health indicator color
    // In a real app, you'd use more sophisticated medical criteria

    try {
      // BP check
      final bpValue = int.tryParse(bp.replaceAll(RegExp(r'[^\d]'), ''));
      final hrValue = int.tryParse(heartRate.replaceAll(RegExp(r'[^\d]'), ''));
      final sugarValue =
          int.tryParse(sugarLevel.replaceAll(RegExp(r'[^\d]'), ''));

      if (bpValue != null && (bpValue < 60 || bpValue > 140)) {
        return Colors.redAccent;
      }

      if (hrValue != null && (hrValue < 60 || hrValue > 100)) {
        return Colors.orangeAccent;
      }

      if (sugarValue != null && (sugarValue < 70 || sugarValue > 140)) {
        return Colors.orangeAccent;
      }

      return Colors.greenAccent;
    } catch (e) {
      return Colors.blueAccent; // Default
    }
  }
}
