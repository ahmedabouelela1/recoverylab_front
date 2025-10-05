import 'dart:core';

class StaffMember {
  final String name;
  final String role;
  final String imageUrl;
  final String bio;
  final double rating;
  final int reviewsCount;
  final List<Map<String, dynamic>> reviews;

  StaffMember({
    required this.name,
    required this.role,
    required this.imageUrl,
    required this.bio,
    this.rating = 4.5,
    this.reviewsCount = 273,
    required this.reviews,
  });
}

// 🔑 Mock Data for Layla Nour with full reviews
final StaffMember mockLayla = StaffMember(
  name: "Layla Nour",
  role: "Senior Massage Therapist",
  imageUrl: 'lib/assets/images/curly.jpg',
  bio:
      "Specializes in deep tissue, Egyptian aromatherapy, and prenatal massage with over 8 years of experience in holistic healing.",
  rating: 4.8,
  reviewsCount: 273,
  reviews: [
    {
      'name': 'Jonas Sousa',
      'role': 'Regular Client',
      'stars': 5,
      'avatarPath': 'lib/assets/images/profile.png',
      'comment':
          'Layla provided an outstanding deep tissue massage. She targeted all my stress points perfectly. Highly recommend!',
    },
    {
      'name': 'Isabela Silveira',
      'role': 'First-time Visitor',
      'stars': 5,
      'avatarPath': 'lib/assets/images/curly.jpg',
      'comment':
          'A truly relaxing experience. Layla has a calming presence and great technique. Will definitely book again.',
    },
    {
      'name': 'Diego Curumim',
      'role': 'Marathon Runner',
      'stars': 4,
      'avatarPath': 'lib/assets/images/profile.png',
      'comment':
          'Fantastic service! Felt completely refreshed. Deducted one star because the room was slightly cold.',
    },
    {
      'name': 'Sula Miranda Silva',
      'role': 'UI Designer',
      'stars': 5,
      'avatarPath': 'lib/assets/images/curly.jpg',
      'comment':
          'The Egyptian aromatherapy was divine. Layla is incredibly professional and skilled.',
    },
    {
      'name': 'Amr Mahmoud',
      'role': 'Local Resident',
      'stars': 4,
      'avatarPath': 'lib/assets/images/profile.png',
      'comment':
          'Very good session overall. The pressure was just right for my back pain. Booking was simple.',
    },
  ],
);
