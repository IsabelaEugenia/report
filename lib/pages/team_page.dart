import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TeamPage extends StatefulWidget {
  final bool isAdmin;
  const TeamPage({super.key, required this.isAdmin});

  @override
  State<TeamPage> createState() => _TeamPageState();
}

class _TeamPageState extends State<TeamPage> {
  // Dados mockados dos funcionários
  final List<Map<String, dynamic>> funcionarios = [
    {'nome': 'Ana Silva', 'cargo': 'Técnica', 'email': 'ana@empresa.com'},
    {'nome': 'Carlos Souza', 'cargo': 'Analista', 'email': 'carlos@empresa.com'},
    {'nome': 'Mariana Lima', 'cargo': 'Gestora', 'email': 'mariana@empresa.com'},
  ];

  // Dados do gráfico — problemas resolvidos por mês
  final List<Map<String, dynamic>> graficoDados = [
    {'mes': 'JAN', 'valor': 18},
    {'mes': 'FEV', 'valor': 24},
    {'mes': 'MAR', 'valor': 20},
    {'mes': 'ABR', 'valor': 35},
  ];

  void _abrirMenuCadastro() {
    final nomeController = TextEditingController();
    final cargoController = TextEditingController();
    final emailController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            top: 24,
            left: 24,
            right: 24,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Barra superior
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xffe0e0e0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Cadastrar Funcionário',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              _inputField(nomeController, 'Nome completo'),
              const SizedBox(height: 14),
              _inputField(cargoController, 'Cargo'),
              const SizedBox(height: 14),
              _inputField(emailController, 'E-mail'),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xffa61d2d),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
                    if (nomeController.text.isNotEmpty) {
                      setState(() {
                        funcionarios.add({
                          'nome': nomeController.text,
                          'cargo': cargoController.text,
                          'email': emailController.text,
                        });
                      });
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Cadastrar'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _inputField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xfff4f5f7),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final maxValor = graficoDados
        .map((e) => e['valor'] as int)
        .reduce((a, b) => a > b ? a : b);

    return SafeArea(
      child: Column(
        children: [
          // ── Cabeçalho com foto de fundo ──
          Stack(
            children: [
              // Imagem de fundo (use uma imagem real no seu projeto)
              Container(
                height: 260,
                width: double.infinity,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(
                      'https://images.unsplash.com/photo-1522071820081-009f0129c71c?w=800',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              // Overlay escuro
              Container(
                height: 260,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.5),
                      Colors.black.withValues(alpha: 0.75),
                    ],
                  ),
                ),
              ),
              // Conteúdo sobre a imagem
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Minha empresa',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      // Três barrinhas — só para admin
                      if (widget.isAdmin)
                        IconButton(
                          onPressed: _abrirMenuCadastro,
                          icon: const Icon(
                            Icons.menu,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 24,
                left: 20,
                right: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nome da Empresa',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${funcionarios.length} colaboradores registrados',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ── Gráfico ──
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ocorrências atendidas pela empresa',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xffa61d2d),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 180,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: graficoDados.map((dado) {
                        final isUltimo = dado == graficoDados.last;
                        final altura =
                            (dado['valor'] as int) / maxValor * 150;
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              '${dado['valor']}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isUltimo
                                    ? const Color(0xffa61d2d)
                                    : Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 4),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 600),
                              curve: Curves.easeOut,
                              width: 48,
                              height: altura,
                              decoration: BoxDecoration(
                                color: isUltimo
                                    ? const Color(0xffa61d2d)
                                    : const Color(0xffb0b0b0),
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(8),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              dado['mes'],
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ── Lista de funcionários ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Equipe',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (widget.isAdmin)
                        TextButton.icon(
                          onPressed: _abrirMenuCadastro,
                          icon: const Icon(Icons.person_add_outlined,
                              size: 18, color: Color(0xffa61d2d)),
                          label: const Text(
                            'Adicionar',
                            style: TextStyle(color: Color(0xffa61d2d)),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...funcionarios.map(
                    (f) => Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xffe8e8e8)),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: const Color(0xffa61d2d),
                            child: Text(
                              f['nome'][0],
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                f['nome'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                f['cargo'],
                                style: const TextStyle(
                                  color: Color(0xff7a7a7a),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
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
}