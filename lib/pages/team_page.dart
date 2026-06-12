import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TeamPage extends StatefulWidget {
  final bool isAdmin;
  const TeamPage({super.key, required this.isAdmin});

  @override
  State<TeamPage> createState() => _TeamPageState();
}

class _TeamPageState extends State<TeamPage> {
  String _gerarEmailInstitucional(String nome) {
  return '${nome
      .trim()
      .toLowerCase()
      .replaceAll(' ', '.')
      .replaceAll('á', 'a')
      .replaceAll('à', 'a')
      .replaceAll('ã', 'a')
      .replaceAll('â', 'a')
      .replaceAll('é', 'e')
      .replaceAll('ê', 'e')
      .replaceAll('í', 'i')
      .replaceAll('ó', 'o')
      .replaceAll('ô', 'o')
      .replaceAll('õ', 'o')
      .replaceAll('ú', 'u')
      .replaceAll('ç', 'c')}@empresa.com';
}
  void _abrirCadastroCategoria() async {

    final nomeController = TextEditingController();

    final setoresSnapshot = await FirebaseFirestore.instance
        .collection('setores')
        .get();

    final setores = setoresSnapshot.docs
        .map((doc) {
          final data = doc.data();

          final nome = data['nome']?.toString() ?? doc.id;
          final setor = data['setor']?.toString() ?? doc.id;

          return {'id': doc.id, 'nome': nome, 'setor': setor};
        })
        .where((setor) {
          return setor['setor']!.isNotEmpty;
        })
        .toList();

    if (setores.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cadastre um setor primeiro.')),
      );
      return;
    }

    print('vai abrir modal de categoria');

    String setorSelecionado = setores.first['setor']!;
    String setorNomeSelecionado = setores.first['nome']!;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateModal) {
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
                  const Text(
                    'Cadastrar Categoria',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 20),

                  _inputField(
                    nomeController,
                    'Nome da categoria. Ex: Informática',
                  ),

                  const SizedBox(height: 14),

                  DropdownButtonFormField<String>(
                    value: setorSelecionado,
                    decoration: InputDecoration(
                      hintText: 'Setor responsável',
                      filled: true,
                      fillColor: const Color(0xfff4f5f7),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    items: setores.map((setor) {
                      return DropdownMenuItem<String>(
                        value: setor['setor']!,
                        child: Text(setor['nome']!),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value == null) return;

                      final setorEncontrado = setores.firstWhere(
                        (s) => s['setor'] == value,
                      );

                      setStateModal(() {
                        setorSelecionado = value;
                        setorNomeSelecionado = setorEncontrado['nome']!;
                      });
                    },
                  ),

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
                      onPressed: () async {
                        final nome = nomeController.text.trim();

                        if (nome.isEmpty) return;

                        final codigo = nome
                            .toLowerCase()
                            .replaceAll(' ', '_')
                            .replaceAll('á', 'a')
                            .replaceAll('à', 'a')
                            .replaceAll('ã', 'a')
                            .replaceAll('é', 'e')
                            .replaceAll('ê', 'e')
                            .replaceAll('í', 'i')
                            .replaceAll('ó', 'o')
                            .replaceAll('õ', 'o')
                            .replaceAll('ú', 'u')
                            .replaceAll('ç', 'c');

                        await FirebaseFirestore.instance
                            .collection('categorias')
                            .doc(codigo)
                            .set({
                              'nome': nome,
                              'setor': setorSelecionado,
                              'setorNome': setorNomeSelecionado,
                            });

                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      },
                      child: const Text('Salvar Categoria'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Dados mockados dos funcionários
  final List<Map<String, dynamic>> funcionarios = [
    {'nome': 'Ana Silva', 'cargo': 'Técnica', 'email': 'ana@empresa.com'},
    {
      'nome': 'Carlos Souza',
      'cargo': 'Analista',
      'email': 'carlos@empresa.com',
    },
    {
      'nome': 'Mariana Lima',
      'cargo': 'Gestora',
      'email': 'mariana@empresa.com',
    },
  ];

  // Dados do gráfico — problemas resolvidos por mês
  final List<Map<String, dynamic>> graficoDados = [
    {'mes': 'JAN', 'valor': 18},
    {'mes': 'FEV', 'valor': 24},
    {'mes': 'MAR', 'valor': 20},
    {'mes': 'ABR', 'valor': 35},
  ];

  void _abrirCadastroSetor() {
    final nomeController = TextEditingController();
    final codigoController = TextEditingController();
    final responsavelController = TextEditingController();

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
              const Text(
                'Cadastrar Setor',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              _inputField(nomeController, 'Nome do setor. Ex: TI'),
              const SizedBox(height: 14),

              _inputField(codigoController, 'Código. Ex: ti'),
              const SizedBox(height: 14),

              _inputField(
                responsavelController,
                'Responsável. Ex: Equipe de TI',
              ),
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
                  onPressed: () async {
                    final nome = nomeController.text.trim();
                    final codigo = codigoController.text.trim().toLowerCase();
                    final responsavel = responsavelController.text.trim();

                    if (nome.isEmpty || codigo.isEmpty) return;

                    await FirebaseFirestore.instance
                        .collection('setores')
                        .doc(codigo)
                        .set({
                          'nome': nome,
                          'setor': codigo,
                          'responsavel': responsavel,
                        });

                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Salvar Setor'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _abrirMenuCadastro() async {
  final nomeController = TextEditingController();
  final cargoController = TextEditingController();

  final setoresSnapshot = await FirebaseFirestore.instance
      .collection('setores')
      .get();

  final setores = setoresSnapshot.docs.map((doc) {
    final data = doc.data();

    final nome = data['nome']?.toString() ?? doc.id;
    final setor = data['setor']?.toString() ?? doc.id;

    return {
      'id': doc.id,
      'nome': nome,
      'setor': setor,
    };
  }).where((setor) {
    return setor['setor']!.isNotEmpty;
  }).toList();

  if (setores.isEmpty) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cadastre um setor primeiro.')),
    );
    return;
  }

  String setorSelecionado = setores.first['setor']!;
  String setorNomeSelecionado = setores.first['nome']!;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setStateModal) {
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

                DropdownButtonFormField<String>(
                  value: setorSelecionado,
                  decoration: InputDecoration(
                    hintText: 'Setor',
                    filled: true,
                    fillColor: const Color(0xfff4f5f7),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: setores.map((setor) {
                    return DropdownMenuItem<String>(
                      value: setor['setor']!,
                      child: Text(setor['nome']!),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value == null) return;

                    final setorEncontrado = setores.firstWhere(
                      (s) => s['setor'] == value,
                    );

                    setStateModal(() {
                      setorSelecionado = value;
                      setorNomeSelecionado = setorEncontrado['nome']!;
                    });
                  },
                ),

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
                    onPressed: () async {
                      final nome = nomeController.text.trim();
                      final cargo = cargoController.text.trim();

                      if (nome.isEmpty || cargo.isEmpty) return;

                      final emailGerado = _gerarEmailInstitucional(nome);

                      await FirebaseFirestore.instance
                          .collection('usuarios')
                          .add({
                        'nome': nome,
                        'cargo': cargo,
                        'email': emailGerado,
                        'tipo': 'funcionario',
                        'setor': setorSelecionado,
                        'setorNome': setorNomeSelecionado,
                        'senhaTemporaria': true,
                      });

                      setState(() {
                        funcionarios.add({
                          'nome': nome,
                          'cargo': cargo,
                          'email': emailGerado,
                          'setor': setorSelecionado,
                        });
                      });

                      if (context.mounted) {
                        Navigator.pop(context);

                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text('Funcionário cadastrado'),
                              content: Text(
                                'Email gerado:\n$emailGerado\n\nSenha temporária:\n123456\n\nAgora crie esse usuário no Firebase Authentication com essa senha.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('OK'),
                                ),
                              ],
                            );
                          },
                        );
                      }
                    },
                    child: const Text('Cadastrar Funcionário'),
                  ),
                ),
              ],
            ),
          );
        },
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
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
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
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Minha empresa',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
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
                    height: 220,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: graficoDados.map((dado) {
                        final isUltimo = dado == graficoDados.last;
                        final altura = (dado['valor'] as int) / maxValor * 140;
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Equipe',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      if (widget.isAdmin) ...[
                        const SizedBox(height: 8),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              TextButton.icon(
                                onPressed: _abrirCadastroSetor,
                                icon: const Icon(
                                  Icons.apartment_outlined,
                                  size: 18,
                                  color: Color(0xffa61d2d),
                                ),
                                label: const Text(
                                  'Setor',
                                  style: TextStyle(color: Color(0xffa61d2d)),
                                ),
                              ),
                              TextButton.icon(
                                onPressed: _abrirCadastroCategoria,
                                icon: const Icon(
                                  Icons.category_outlined,
                                  size: 18,
                                  color: Color(0xffa61d2d),
                                ),
                                label: const Text(
                                  'Categoria',
                                  style: TextStyle(color: Color(0xffa61d2d)),
                                ),
                              ),
                              TextButton.icon(
                                onPressed: _abrirMenuCadastro,
                                icon: const Icon(
                                  Icons.person_add_outlined,
                                  size: 18,
                                  color: Color(0xffa61d2d),
                                ),
                                label: const Text(
                                  'Funcionário',
                                  style: TextStyle(color: Color(0xffa61d2d)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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
