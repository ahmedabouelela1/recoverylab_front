enum BookingStatus { upcoming, completed, cancelled }

class Booking {
  final String id;
  final String title;
  final String location;
  final String date;
  final String time;
  final String duration;
  //final double rating;
  final String imageUrl;
  final BookingStatus status;
  final String description;
  final String? selectedStaffName;
  final String? serviceName;

  const Booking({
    required this.id,
    required this.title,
    required this.location,
    required this.date,
    required this.time,
    required this.duration,
    //required this.rating,
    required this.imageUrl,
    required this.status,
    required this.description,
    this.selectedStaffName,
    this.serviceName,
  });

  // Utility method to create a copy, changing only specified fields
  Booking copyWith({
    String? id,
    String? title,
    String? location,
    String? date,
    String? time,
    String? duration,
    double? rating,
    String? imageUrl,
    BookingStatus? status,
    String? description,
    String? selectedStaffName,
    String? serviceName,
  }) {
    return Booking(
      id: id ?? this.id,
      title: title ?? this.title,
      location: location ?? this.location,
      date: date ?? this.date,
      time: time ?? this.time,
      duration: duration ?? this.duration,
      //rating: rating ?? this.rating,
      imageUrl: imageUrl ?? this.imageUrl,
      status: status ?? this.status,
      description: description ?? this.description,
      selectedStaffName: selectedStaffName ?? this.selectedStaffName,
      serviceName: serviceName ?? this.serviceName,
    );
  }
}
