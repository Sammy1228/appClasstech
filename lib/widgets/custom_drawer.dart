import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/provider_autenticacion.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<Authentication>(
      builder: (context, auth, child) {
        // Obtenemos el tipo de usuario (normalizado a minúsculas por seguridad)
        final tipoUsuario = auth.tipoUsuario.toLowerCase();

        return Drawer(
          child: Container(
            color: const Color(0xFF6443D9),
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                UserAccountsDrawerHeader(
                  decoration: const BoxDecoration(color: Color(0xFF6443D9)),
                  currentAccountPicture: Image.asset(
                    "assets/images/logo.png",
                    width: 70,
                    height: 70,
                  ),
                  accountName: Text(
                    "${auth.nombre} ${auth.apellidos}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  accountEmail: Text(
                    auth.email,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
                _drawerItem(
                  icon: Icons.home,
                  text: "Home",
                  onTap: () {
                    Navigator.pushReplacementNamed(context, '/dashboard');
                  },
                ),
                _drawerItem(
                  icon: Icons.person,
                  text: "Perfil",
                  onTap: () {
                    Navigator.pushReplacementNamed(context, '/perfil');
                  },
                ),

                // 🔒 VISIBLE SOLO PARA PROFESORES
                if (tipoUsuario == 'profesor')
                  _drawerItem(
                    icon: Icons.settings,
                    text: "Listas de estudiantes",
                    onTap: () {
                      Navigator.pushReplacementNamed(context, '/config');
                    },
                  ),

                _drawerItem(
                  icon: Icons.book,
                  text: "Clases",
                  onTap: () {
                    Navigator.pushReplacementNamed(context, '/class');
                  },
                ),
                _drawerItem(
                  icon: Icons.feedback,
                  text: "Retroalimentación",
                  onTap: () {
                    Navigator.pushReplacementNamed(
                      context,
                      '/retroalimentacion',
                    );
                  },
                ),
                const Divider(color: Colors.white24),
                _drawerItem(
                  icon: Icons.logout,
                  text: "Cerrar Sesión",
                  onTap: () {
                    final authProvider = Provider.of<Authentication>(
                      context,
                      listen: false,
                    );
                    authProvider.logout();
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _drawerItem({
    required IconData icon,
    required String text,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(text, style: const TextStyle(color: Colors.white)),
      onTap: onTap,
    );
  }
}
