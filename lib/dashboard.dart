import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_drawer.dart';
import '../Utils/responsive.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        title: Text(
          "Panel principal",
          style: TextStyle(
            fontSize: responsive.dp(2.2),
            color: AppTheme.backgroundColor,
          ),
        ),
      ),
      drawer: const CustomDrawer(),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(responsive.wp(4)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Resumen de actividades",
              style: TextStyle(
                fontSize: responsive.dp(2.1),
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            SizedBox(height: responsive.hp(2)),

            // Tarjetas horizontales
            SizedBox(
              height: responsive.hp(18),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildStatCard(
                    responsive,
                    "Total actividades",
                    "12",
                    Icons.assignment,
                    AppTheme.secondaryColor,
                  ),
                  SizedBox(width: responsive.wp(4)),
                  _buildStatCard(
                    responsive,
                    "Pendientes",
                    "4",
                    Icons.schedule,
                    Colors.orange,
                  ),
                  SizedBox(width: responsive.wp(4)),
                  _buildStatCard(
                    responsive,
                    "Completadas",
                    "8",
                    Icons.check_circle,
                    Colors.green,
                  ),
                ],
              ),
            ),

            SizedBox(height: responsive.hp(3)),

            Text(
              "Actividades recientes",
              style: TextStyle(
                fontSize: responsive.dp(2),
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryColor,
              ),
            ),
            SizedBox(height: responsive.hp(2)),

            // Lista vertical simulada
            Column(
              children: List.generate(4, (index) {
                return Container(
                  margin: EdgeInsets.only(bottom: responsive.hp(1.5)),
                  padding: EdgeInsets.all(responsive.wp(4)),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(responsive.dp(1.5)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: responsive.dp(0.5),
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.bookmark,
                        color: AppTheme.secondaryColor,
                        size: responsive.dp(3),
                      ),
                      SizedBox(width: responsive.wp(3)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Actividad ${index + 1}",
                              style: TextStyle(
                                fontSize: responsive.dp(1.9),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: responsive.hp(0.5)),
                            Text(
                              "Descripción breve de la actividad ${index + 1}.",
                              style: TextStyle(
                                fontSize: responsive.dp(1.6),
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    Responsive responsive,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      width: responsive.wp(42),
      padding: EdgeInsets.all(responsive.wp(4)),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(responsive.dp(2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: responsive.dp(4)),
          SizedBox(height: responsive.hp(1)),
          Text(
            value,
            style: TextStyle(
              fontSize: responsive.dp(3),
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: responsive.hp(0.5)),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: responsive.dp(1.6),
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
