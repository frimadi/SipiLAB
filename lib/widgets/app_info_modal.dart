import 'package:flutter/material.dart';

class AppInfoModal extends StatelessWidget {
  const AppInfoModal({super.key});

  
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AppInfoModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (_, controller) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
             
              Expanded(
                child: ListView(
                  controller: controller,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  children: [
                    const Text(
                      "Tentang Aplikasi",
                      style: TextStyle(
                        fontSize: 22, 
                        fontWeight: FontWeight.bold, 
                        color: Color(0xFF0F172A)
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),

                    _buildSectionTitle("Deskripsi"),
                    const SizedBox(height: 12),
                    const Text(
                      "Aplikasi Laboratorium Teknik ini dirancang untuk memudahkan pencatatan, perhitungan, dan pelaporan hasil uji tanah (Sand Cone) dan beton (Hammer Test & Uji Kuat Tekan) secara digital. Membantu efisiensi kerja surveyor di lapangan dan analis di laboratorium.",
                      style: TextStyle(color: Color(0xFF64748B), height: 1.6, fontSize: 15),
                      textAlign: TextAlign.justify,
                    ),
                    const SizedBox(height: 30),

                    _buildSectionTitle("Pengembang"),
                    const SizedBox(height: 16),
                    _buildDeveloperCard(),
                    
                    const SizedBox(height: 40),
                    
                    Center(
                      child: Column(
                        children: [
                          Icon(Icons.verified_user_outlined, color: Colors.grey[400], size: 40),
                          const SizedBox(height: 8),
                          Text("Versi 1.0.0", style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4, 
          height: 20, 
          color: const Color(0xFF6366F1), 
          margin: const EdgeInsets.only(right: 10),
        ),
        Text(
          title, 
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))
        ),
      ],
    );
  }

  Widget _buildDeveloperCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 32,
            backgroundColor: Color(0xFF6366F1),
            child: Icon(Icons.person_rounded, size: 32, color: Colors.white),
            // backgroundImage: AssetImage('assets/profil.jpg'), // Aktifkan jika ada foto
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Nama Developer", 
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F172A)),
                ),
                SizedBox(height: 4),
                Text("M.Cahyo Basuki Pratama", style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                SizedBox(height: 4),
                Text("cahyosampit78@gmail.com", style: TextStyle(color: Color(0xFF6366F1), fontSize: 13, fontWeight: FontWeight.w500)),
              ],
            ),
          )
        ],
      ),
    );
  }
}