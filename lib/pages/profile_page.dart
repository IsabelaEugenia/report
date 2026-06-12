import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';



class ProfilePage extends StatelessWidget {
  final bool isAdmin;
  final String setor;
  final String nome;
  final String email;
  final String cargo;
  final String setorNome;
  final String telefone;
  final List<Map<String, dynamic>>? ocorrencias;

  const ProfilePage({
    super.key,
    required this.isAdmin,
    required this.setor,
    required this.nome,
    required this.email,
    required this.cargo,
    required this.setorNome,
    required this.ocorrencias,
    required this.telefone,
  });

  @override
  Widget build(BuildContext context) {
    final listaOcorrencias = ocorrencias ?? [];

    final quantidadeOcorrencias = isAdmin
        ? listaOcorrencias.length
        : listaOcorrencias.where((o) => o['setor'] == setor).length;
        
    final nomeController = TextEditingController(text: nome);
    final cargoController = TextEditingController(text: cargo);
    final telefoneController = TextEditingController(text: telefone);

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
                nome,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                email,
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
                      cargo.isEmpty ? (isAdmin ? 'Administrador' : 'Funcionário') : cargo,
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
                      quantidadeOcorrencias.toString(), 
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
              buildField('Nome Completo', nomeController),
              buildField('E-mail', TextEditingController(text: email), readOnly: true),
              buildField('Telefone', telefoneController),
              buildField('Cargo', cargoController),
              buildField('Departamento', TextEditingController(text: setorNome), readOnly: true),

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
                 onPressed: () async {
                  final snapshot = await FirebaseFirestore.instance
                      .collection('usuarios')
                      .where('email', isEqualTo: email)
                      .get();

                  if (snapshot.docs.isEmpty) return;

                  await snapshot.docs.first.reference.update({
                    'nome': nomeController.text.trim(),
                    'cargo': cargoController.text.trim(),
                    'telefone': telefoneController.text.trim(),
                  });

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Alterações salvas com sucesso.'),
                      ),
                    );
                    Future.delayed(const Duration(seconds: 1), () {
                    if (context.mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                        (route) => false,
                      );
                    }
                  });
                  }
                },
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
  return SizedBox(
    width: 220, // aumenta a largura
    height: 160, // aumenta a altura
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xfff8f8f8),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 34,
              color: const Color(0xffa61d2d),
            ),
            const SizedBox(height: 12),
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xff7a7a7a),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              valor,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
  );
}

  Widget buildField(
  String titulo,
  TextEditingController controller, {
  bool readOnly = false,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: Column(
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
          controller: controller,
          readOnly: readOnly,
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
    ),
  );
}
}