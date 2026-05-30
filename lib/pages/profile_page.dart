import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart';



class ProfilePage extends StatelessWidget {
  final bool isAdmin;
  const ProfilePage({super.key, required this.isAdmin});

@override
Widget build(BuildContext context) {
  return SafeArea(
    child: Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Container(
          width: 700,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0xffe8e8e8)),
          ),
          child: Column(
            children: [
              Text(
                isAdmin ? 'Perfil do Administrador' : 'Meu Perfil',
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              CircleAvatar(
                radius: 55,
                backgroundColor: const Color(0xffa61d2d),
                child: Text(
                  'A',
                  style: GoogleFonts.inter(
                    fontSize: 42,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                isAdmin ? 'Administrador Master' : 'Nome do Funcionário',
                style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isAdmin ? 'admin@reportplus.com' : 'funcionario@empresa.com',
                style: const TextStyle(
                  color: Color(0xff7a7a7a),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: infoCard(
                      'Cargo',
                      isAdmin ? 'Administrador' : 'Funcionário',
                      Icons.admin_panel_settings_outlined,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: infoCard(
                      'Acesso',
                      isAdmin ? 'Total' : 'Limitado',
                      Icons.lock_open_outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: infoCard(
                      'Ocorrências',
                      isAdmin ? '128' : '12',
                      Icons.warning_amber_outlined,
                    ),
                  ),
                  if (isAdmin) ...[
                    const SizedBox(width: 16),
                    Expanded(
                      child: infoCard(
                        'Equipe',
                        '24 membros',
                        Icons.groups_outlined,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 32),
              buildField('Nome Completo', isAdmin ? 'Administrador Master' : 'Nome do Funcionário'),
              const SizedBox(height: 20),
              buildField('E-mail', isAdmin ? 'admin@reportplus.com' : 'funcionario@empresa.com'),
              const SizedBox(height: 20),
              buildField('Telefone', '(14) 99999-9999'),
              const SizedBox(height: 20),
              buildField('Departamento', isAdmin ? 'TI / Segurança' : 'Operacional'),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xffa61d2d),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  onPressed: () {},
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Salvar Alterações'),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xffa61d2d),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil( // Vai para o login
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                      (route) => false, // tira as outras rotas
                    );
                  },
                  icon: const Icon(Icons.logout_outlined),
                  label: const Text('Sair'),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

  Widget infoCard(
    String titulo,
    String valor,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: const Color(0xfff8f8f8),
        borderRadius: BorderRadius.circular(22),
      ),

      child: Column(
        children: [
          Icon(
            icon,
            size: 34,
            color: const Color(0xffa61d2d),
          ),

          const SizedBox(height: 12),

          Text(
            titulo,
            style: const TextStyle(
              color: Color(0xff7a7a7a),
            ),
          ),

          const SizedBox(height: 6),

          Text(
            valor,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildField(
    String titulo,
    String valor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Text(
          titulo,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 10),

        TextField(
          controller: TextEditingController(text: valor),

          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,

            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 18,
            ),

            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(
                color: Color(0xffe8e8e8),
              ),
            ),

            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(
                color: Color(0xffe8e8e8),
              ),
            ),

            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(
                color: Color(0xffa61d2d),
              ),
            ),
          ),
        ),
      ],
    );
  }
}