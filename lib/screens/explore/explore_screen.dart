// lib/screens/explore/explore_screen.dart
import 'package:flutter/material.dart';

import '../../models/destination.dart';
import 'destination_card.dart';
import 'destination_detail_screen.dart';
import 'featured_card.dart';

// Demo destinations – ei data diyei Featured & Popular duita fill hobe
final List<Destination> demoDestinations = [
  Destination(
    id: '1',
    name: "Cox's Bazar",
    country: 'Bangladesh',
    category: 'Beach',
    imageUrl:
        'https://images.pexels.com/photos/4090625/pexels-photo-4090625.jpeg',
    rating: 4.7,
    bestTime: 'November – March',
    description:
        "World’s longest natural sea beach with golden sand, warm water and stunning sunsets.",
  ),
  Destination(
    id: '2',
    name: 'Santorini',
    country: 'Greece',
    category: 'Island',
    imageUrl:
        'https://images.pexels.com/photos/1285625/pexels-photo-1285625.jpeg',
    rating: 4.8,
    bestTime: 'April – October',
    description:
        'Whitewashed villages, blue domes and dramatic cliffs overlooking the Aegean Sea.',
  ),
  Destination(
    id: '3',
    name: 'Kyoto',
    country: 'Japan',
    category: 'Culture',
    imageUrl:
        'https://images.pexels.com/photos/1673978/pexels-photo-1673978.jpeg',
    rating: 4.9,
    bestTime: 'March – May, October – November',
    description:
        'Temples, cherry blossoms, tea houses and traditional streets full of history.',
  ),
  Destination(
    id: '4',
    name: 'Paris',
    country: 'France',
    category: 'City break',
    imageUrl:
        'https://images.pexels.com/photos/338515/pexels-photo-338515.jpeg',
    rating: 4.6,
    bestTime: 'April – June, September – October',
    description:
        'Iconic landmarks, cafés, museums and romantic walks along the Seine.',
  ),
  Destination(
    id: '5',
    name: 'Bali',
    country: 'Indonesia',
    category: 'Tropical',
    imageUrl:
        'https://images.pexels.com/photos/2166553/pexels-photo-2166553.jpeg',
    rating: 4.8,
    bestTime: 'April – October',
    description:
        'Rice terraces, surf beaches, waterfalls and laid-back island vibes.',
  ),
];

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Destination> featured = demoDestinations.take(3).toList();

    return Scaffold(
      body: Container( 
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF050816),
              Color(0xFF050816),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
            children: [
              const Center(
                  child: Text(
                    "Explore What's Trending!",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              const SizedBox(height: 12),

              TextField(
                decoration: const InputDecoration(
                  hintText: 'Search cities, countries, or experiences',
                  prefixIcon: Icon(Icons.search_rounded),
                ),
              ),

              const SizedBox(height: 24),

              // ---------- Featured this week ----------
              Row(
                children: [
                  const Text(
                    'Featured this week',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {},
                    child: const Text('See all'),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              SizedBox(
                height: 230,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: featured.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 14),
                  itemBuilder: (context, index) {
                    final dest = featured[index];
                    return SizedBox(
                      width: 260,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  DestinationDetailScreen(destination: dest),
                            ),
                          );
                        },
                        child: FeaturedCard(destination: dest),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              // ---------- Popular destinations ----------
              const Text(
                'Popular destinations',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),

              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: demoDestinations.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.13,
                ),
                itemBuilder: (context, index) {
                  final dest = demoDestinations[index];
                  return DestinationCard(
                    destination: dest,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              DestinationDetailScreen(destination: dest),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
