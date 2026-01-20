import 'package:flutter/material.dart';

class ResponsiveHome extends StatelessWidget {
  const ResponsiveHome({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;

    return Scaffold(
      appBar: AppBar(title: const Text('CampConnect'), centerTitle: true),
      body: Padding(
        padding: EdgeInsets.all(isTablet ? 24 : 16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              children: [
                /// HEADER
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Discover Campus Events',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: isTablet ? 26 : 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                /// MAIN CONTENT
                Expanded(
                  child: isTablet
                      ? GridView.count(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          children: List.generate(
                            4,
                            (index) => _EventCard(isTablet: isTablet),
                          ),
                        )
                      : ListView.separated(
                          itemCount: 4,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (_, index) =>
                              _EventCard(isTablet: isTablet),
                        ),
                ),

                const SizedBox(height: 16),

                /// FOOTER / ACTION
                SizedBox(
                  width: double.infinity,
                  height: isTablet ? 56 : 48,
                  child: ElevatedButton(
                    onPressed: () {},
                    child: Text(
                      'Explore Events',
                      style: TextStyle(fontSize: isTablet ? 18 : 16),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final bool isTablet;

  const _EventCard({required this.isTablet});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: isTablet ? 3 / 2 : 4 / 2,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Tech Talk',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'Join us for an exciting session on mobile development.',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
