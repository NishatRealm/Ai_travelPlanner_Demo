import 'package:flutter/material.dart';

import '../../services/ai_service.dart';

class TripPlannerScreen extends StatefulWidget {
  const TripPlannerScreen({super.key});

  @override
  State<TripPlannerScreen> createState() => _TripPlannerScreenState();
}

class _TripPlannerScreenState extends State<TripPlannerScreen> {
  final _cityCtrl = TextEditingController();
  final _daysCtrl = TextEditingController(text: "3");
  final _peopleCtrl = TextEditingController(text: "2");

  String? aiPlan;
  bool _loading = false;

  @override
  void dispose() {
    _cityCtrl.dispose();
    _daysCtrl.dispose();
    _peopleCtrl.dispose();
    super.dispose();
  }

  Future<void> _generatePlan() async {
    final city = _cityCtrl.text.trim();
    final days = int.tryParse(_daysCtrl.text.trim()) ?? 3;
    final people = int.tryParse(_peopleCtrl.text.trim()) ?? 2;

    if (city.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a destination')),
      );
      return;
    }

    setState(() {
      _loading = true;
      aiPlan = null;
    });

    try {
      final plan = await AIService.generatePlan(city, days, people);
      if (!mounted) return;
      setState(() {
        aiPlan = plan;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        aiPlan =
            'Sorry, something went wrong while generating your itinerary.';
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip planner', style: TextStyle(color: Colors.white)),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF050816),
              Color(0xFF09152B),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.08),
                  ),
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: _cityCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Destination city',
                        prefixIcon: Icon(Icons.location_city_rounded),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _daysCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Days',
                              prefixIcon: Icon(Icons.calendar_today_rounded),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _peopleCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'People',
                              prefixIcon: Icon(Icons.group_rounded),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _loading ? null : _generatePlan,
                        icon: _loading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.auto_awesome_rounded),
                        label: Text(
                          _loading
                              ? 'Generating itinerary…'
                              : 'Generate with AI',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.06),
                    ),
                  ),
                  child: aiPlan == null
                      ? Center(
                          child: Text(
                            'Your AI-powered itinerary will appear here.\nInclude what you like (budget, interests, pace)…',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        )
                      : SingleChildScrollView(
                          child: Text(
                            aiPlan!,
                            style: const TextStyle(fontSize: 15, height: 1.4),
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
