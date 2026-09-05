import 'package:flutter/material.dart';

void main() {
  runApp(const SEERAdminDashboard());
}

class SEERAdminDashboard extends StatelessWidget {
  const SEERAdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SEER Admin Dashboard',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Arial',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1565C0),
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
      ),
      home: const AdminDashboard(),
    );
  }
}

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int selectedIndex = 0;

  final List<String> menuItems = [
    'Dashboard',
    'Schools',
    'Students',
    'Drivers',
    'Buses',
    'Trips',
    'Routes',
    'Attendance',
    'Reports',
    'Safety Incidents',
  ];

  final List<IconData> menuIcons = [
    Icons.dashboard_outlined,
    Icons.school_outlined,
    Icons.people_outline,
    Icons.badge_outlined,
    Icons.directions_bus_outlined,
    Icons.route_outlined,
    Icons.map_outlined,
    Icons.fact_check_outlined,
    Icons.analytics_outlined,
    Icons.warning_amber_outlined,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          _buildSidebar(),
          Expanded(
            child: Column(
              children: [
                _buildTopBar(),
                Expanded(
                  child: _buildMainContent(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 250,
      color: const Color(0xFF0D47A1),
      child: Column(
        children: [
          const SizedBox(height: 28),

          // Logo
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.directions_bus_rounded,
                color: Colors.white,
                size: 38,
              ),
              SizedBox(width: 10),
              Text(
                'SEER',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          const Text(
            'Smart School Bus System',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 11,
            ),
          ),

          const SizedBox(height: 35),

          Expanded(
            child: ListView.builder(
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                final selected = selectedIndex == index;

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 3,
                  ),
                  child: Material(
                    color: selected
                        ? Colors.white.withOpacity(0.18)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () {
                        setState(() {
                          selectedIndex = index;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 13,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              menuIcons[index],
                              color: Colors.white,
                              size: 21,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                menuItems[index],
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: selected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const Divider(
            color: Colors.white24,
            indent: 20,
            endIndent: 20,
          ),

          Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.white24,
                  child: Icon(
                    Icons.admin_panel_settings,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Administrator',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Admin Account',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.logout,
                    color: Colors.white70,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      height: 75,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFE5E7EB),
          ),
        ),
      ),
      child: Row(
        children: [
          Text(
            menuItems[selectedIndex],
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),

          const Spacer(),

          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none),
          ),

          const SizedBox(width: 8),

          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(50),
            ),
            child: const Icon(
              Icons.person_outline,
              color: Color(0xFF1565C0),
            ),
          ),

          const SizedBox(width: 10),

          const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Admin',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              Text(
                'Administrator',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    if (selectedIndex != 0) {
      return _buildPlaceholderPage(menuItems[selectedIndex]);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Welcome to SEER',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'School transportation monitoring and management dashboard.',
            style: TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 28),

          _buildStatistics(),

          const SizedBox(height: 28),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: _buildBusMonitoring(),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _buildSystemStatus(),
              ),
            ],
          ),

          const SizedBox(height: 28),

          _buildQuickActions(),
        ],
      ),
    );
  }

  Widget _buildStatistics() {
    final cards = [
      {
        'title': 'Schools',
        'value': '0',
        'icon': Icons.school_outlined,
      },
      {
        'title': 'Students',
        'value': '0',
        'icon': Icons.people_outline,
      },
      {
        'title': 'Drivers',
        'value': '0',
        'icon': Icons.badge_outlined,
      },
      {
        'title': 'Buses',
        'value': '0',
        'icon': Icons.directions_bus_outlined,
      },
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        int columns = 4;

        if (width < 1000) {
          columns = 2;
        }

        if (width < 600) {
          columns = 1;
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: cards.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 18,
            mainAxisSpacing: 18,
            childAspectRatio: 2.2,
          ),
          itemBuilder: (context, index) {
            final card = cards[index];

            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFFE5E7EB),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    height: 52,
                    width: 52,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F2FD),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      card['icon'] as IconData,
                      color: const Color(0xFF1565C0),
                      size: 26,
                    ),
                  ),

                  const SizedBox(width: 15),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        card['title'] as String,
                        style: const TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        card['value'] as String,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBusMonitoring() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                color: Color(0xFF1565C0),
              ),
              SizedBox(width: 10),
              Text(
                'Real-Time Bus Monitoring',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Container(
            height: 230,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.map_outlined,
                    size: 55,
                    color: Color(0xFF94A3B8),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'No active buses',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF475569),
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'GPS tracking data will appear here.',
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemStatus() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'System Status',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 22),

          _statusItem(
            'Firebase',
            'Ready',
            Icons.cloud_done_outlined,
          ),

          _statusItem(
            'Database',
            'Ready',
            Icons.storage_outlined,
          ),

          _statusItem(
            'GPS Service',
            'Waiting',
            Icons.gps_fixed,
          ),

          _statusItem(
            'NFC/RFID',
            'Waiting',
            Icons.contactless_outlined,
          ),
        ],
      ),
    );
  }

  Widget _statusItem(
    String title,
    String status,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        children: [
          Icon(
            icon,
            size: 22,
            color: const Color(0xFF1565C0),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 9,
              vertical: 5,
            ),
            decoration: BoxDecoration(
              color: status == 'Ready'
                  ? const Color(0xFFE8F5E9)
                  : const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: status == 'Ready'
                    ? const Color(0xFF2E7D32)
                    : const Color(0xFFE65100),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 18),

          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _actionButton(
                'Add School',
                Icons.add_business_outlined,
                1,
              ),
              _actionButton(
                'Add Student',
                Icons.person_add_outlined,
                2,
              ),
              _actionButton(
                'Add Driver',
                Icons.badge_outlined,
                3,
              ),
              _actionButton(
                'Add Bus',
                Icons.directions_bus_outlined,
                4,
              ),
              _actionButton(
                'Manage Routes',
                Icons.route_outlined,
                6,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionButton(
    String title,
    IconData icon,
    int index,
  ) {
    return OutlinedButton.icon(
      onPressed: () {
        setState(() {
          selectedIndex = index;
        });
      },
      icon: Icon(icon, size: 19),
      label: Text(title),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(9),
        ),
      ),
    );
  }

  Widget _buildPlaceholderPage(String title) {
    return Center(
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              menuIcons[selectedIndex],
              size: 70,
              color: const Color(0xFF1565C0),
            ),

            const SizedBox(height: 20),

            Text(
              title,
              style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              '$title management will be implemented here.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 25),

            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  selectedIndex = 0;
                });
              },
              icon: const Icon(Icons.arrow_back),
              label: const Text('Back to Dashboard'),
            ),
          ],
        ),
      ),
    );
  }
}