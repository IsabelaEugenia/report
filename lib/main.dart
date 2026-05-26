import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'pages/team_page.dart';
import 'pages/profile_page.dart';
import 'pages/search_page.dart';
import 'pages/iniciar_page.dart';


void main() {
  runApp(const ReportPlusApp());
}

class ReportPlusApp extends StatelessWidget {
  const ReportPlusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Report+',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xfff4f5f7),
        textTheme: GoogleFonts.interTextTheme(),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xffa61d2d)),
      ),
      home: const LoadingScreen(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final senhaController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            width: 420,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: const Color(0xffe8e8e8)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Report+',
                  style: GoogleFonts.inter(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xffa61d2d),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Sistema de reporte de problemas',
                  style: TextStyle(color: Color(0xff7a7a7a)),
                ),
                const SizedBox(height: 30),
                TextField(
                  controller: emailController,
                  decoration: inputDecoration('E-mail'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: senhaController,
                  obscureText: true,
                  decoration: inputDecoration('Senha'),
                ),
                const SizedBox(height: 30),
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
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                        builder: (_) => MainScreen(isAdmin: emailController.text == 'admin@empresa.com'),
                        ),
                      );
                    },
                    child: const Text('Entrar'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DashboardPage extends StatefulWidget {
  final bool isAdmin;
  final List<Map<String, dynamic>> ocorrencias;
  const DashboardPage({super.key, required this.isAdmin, required this.ocorrencias});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final pesquisaController = TextEditingController();
  late List<Map<String, dynamic>> filteredOcorrencias;

 
  @override
  void initState() {
    super.initState();
    filteredOcorrencias = List.from(widget.ocorrencias);
  }

  @override
  void dispose() {
    pesquisaController.dispose();
    super.dispose();
  }

  void _searchOcorrencias(String query) {
    setState(() {
      final lowerQuery = query.trim().toLowerCase();
      if (lowerQuery.isEmpty) {
        filteredOcorrencias = List.from(widget.ocorrencias);
      } else {
        filteredOcorrencias = widget.ocorrencias.where((item) {
          return item['titulo'].toString().toLowerCase().contains(lowerQuery) ||
              item['local'].toString().toLowerCase().contains(lowerQuery) ||
              item['descricao'].toString().toLowerCase().contains(lowerQuery) ||
              item['status'].toString().toLowerCase().contains(lowerQuery) ||
              item['prioridade'].toString().toLowerCase().contains(lowerQuery);
        }).toList();
      }
    });
  }

 @override
  Widget build(BuildContext context) {
  final width = MediaQuery.of(context).size.width;
  final isDesktop = width >= 1100;
  final isTablet = width >= 700 && width < 1100;

  return SafeArea(
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1500),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
        Row(
           children: [
           Text('Report+'), 
            const Spacer(),
            Container(
            decoration: BoxDecoration(
             color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
            child: IconButton(
             onPressed: _abrirSobre,   
            icon: const Icon(Icons.info_outline),
      ),
    ),
            const SizedBox(width: 8),
           Container(
           decoration: BoxDecoration(
           color: Colors.white,
           borderRadius: BorderRadius.circular(16),
      ),
           child: IconButton(
           onPressed: () {},
           icon: const Icon(Icons.dark_mode_outlined),
      ),
    ),
  ],
),
                  const SizedBox(height: 20),
                  TextField(
                    controller: pesquisaController,
                    onChanged: _searchOcorrencias,
                    decoration: inputDecoration('Pesquisar ocorrência...')
                        .copyWith(
                          prefixIcon: IconButton(
                            onPressed: () =>
                                _searchOcorrencias(pesquisaController.text),
                            icon: const Icon(Icons.search),
                          ),
                        ),
                  ),
                  const SizedBox(height: 24),

                  if (isDesktop)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 2, child: buildCardsGrid(4)),
                        const SizedBox(width: 24),
                        Expanded(flex: 3, child: buildLista()),
                      ],
                    )
                  else if (isTablet)
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: buildCardsGrid(2)),
                          const SizedBox(width: 18),
                          Expanded(child: buildLista()),
                        ],
                      ),
                    )
                  else
                    Expanded(
                      child: Column(
                        children: [
                          buildCardsGrid(2),
                          const SizedBox(height: 20),
                          Expanded(child: buildLista()),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
  }
              Widget buildCardsGrid(int crossAxisCount) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.8,
      children: [
        estatisticaCard('Ocorrências', '24'),
        estatisticaCard('Alta Prioridade', '8'),
        estatisticaCard('Em Andamento', '11'),
        estatisticaCard('Finalizadas', '13'),
      ],
    );
  }

  Widget estatisticaCard(String titulo, String valor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xffe8e8e8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(titulo, style: const TextStyle(color: Color(0xff7a7a7a))),
          const SizedBox(height: 10),
          Text(
            valor,
            style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget buildLista() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xffe8e8e8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ocorrências Recentes',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.separated(
              itemCount: filteredOcorrencias.length,
              separatorBuilder: (context, index) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final item = filteredOcorrencias[index];

                return occurrenceCard(item);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget occurrenceCard(Map<String, dynamic> item) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () { 
        if (widget.isAdmin) {
       atualizarAndamento(item);
        } else {
       abrirOcorrencia(item);
        }
      }, 
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xfff8f8f8),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['titulo'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item['local'],
                    style: const TextStyle(color: Color(0xff7a7a7a)),
                  ),
                  const SizedBox(height: 8),
                  Text('${item['status']} • ${item['prioridade']}'),
                ],
              ),
            ),
            const SizedBox(width: 16),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xffa61d2d),
              ),
              onPressed: () => abrirOcorrencia(item),
              child: const Text('Abrir'),
            ),
          ],
        ),
      ),
    );
  }

  void abrirOcorrencia(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          child: Container(
            width: 600,
            padding: const EdgeInsets.all(28),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['titulo'],
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  buildInfoField('Local', item['local']),
                  buildInfoField('Descrição', item['descricao']),
                  buildInfoField('Status', item['status']),
                  buildInfoField('Prioridade', item['prioridade']),
                  buildInfoField('Data', item['data']),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xffa61d2d),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Salvar Alterações'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void atualizarAndamento(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['titulo'],
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Atualizar andamento',
                  style: TextStyle(color: Color(0xff7a7a7a)),
                ),
                const SizedBox(height: 24),
                ...['Em análise', 'Em andamento', 'Finalizado'].map(
                  (status) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          side: BorderSide(
                            color: item['status'] == status
                                ? const Color(0xffa61d2d)
                                : const Color(0xffe8e8e8),
                          ),
                          foregroundColor: item['status'] == status
                              ? const Color(0xffa61d2d)
                              : Colors.black,
                        ),
                        onPressed: () {
                          setState(() {
                            item['status'] = status;
                          });
                          Navigator.pop(context);
                        },
                        child: Text(status),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
void _abrirSobre() {
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        child: Container(
          width: 480,
          padding: const EdgeInsets.all(32),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    'Report+',
                    style: GoogleFonts.inter(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xffa61d2d),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                const Center(
                  child: Text(
                    'Sistema de reporte de problemas',
                    style: TextStyle(color: Color(0xff7a7a7a)),
                  ),
                ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 12),

                _sobreItem('Disciplina', 'Desenvolvimento de Software'),
                _sobreItem('Programa', 'Fábrica de Softwares'),
                const SizedBox(height: 8),

                _sobreItem('Professores Responsáveis',
                    'Prof. Dr. Elvio Gilberto da Silva\nProf. Me. Luis Felipe Grael Tinós\nProfessora Esp. Camila Floret Pelizon (professora colaboradora)'),
                const SizedBox(height: 8),

                _sobreItem('Grupo 14',
                    'Bruno Mansano\nDiego Galvão\nIsabela Eugênia\nJoão Igor\nLucas Martins'),
                const SizedBox(height: 8),

                _sobreItem('Sobre o App',
                    'Aplicativo desenvolvido para facilitar o reporte de problemas na empresa, promovendo uma comunicação colaborativa entre funcionários e administradores.'),

                const Divider(height: 32),

                // Logos
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        const Text(
                          'Desenvolvimento:',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff7a7a7a),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Image.network(
                          'https://unisagrado.edu.br/uploads/2008/logotipos/monoliticas_unisagrado/unisagrado.jpg',
                          height: 48,
                          errorBuilder: (_, __, ___) => const Text(
                            'UNISAGRADO',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        const Text(
                          'Apoio:',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff7a7a7a),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Image.network(
                          'https://unisagrado.edu.br/uploads/2008/logotipos/monoliticas_unisagrado/coordenadoria-deextensao.jpg',
                          height: 48,
                          errorBuilder: (_, __, ___) => const Text(
                            'Coordenadoria de Extensão',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xffa61d2d),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Fechar'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

Widget _sobreItem(String titulo, String valor) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xff7a7a7a),
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          valor,
          style: const TextStyle(fontSize: 16),
        ),
      ],
    ),
  );
}

  Widget buildInfoField(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: TextEditingController(text: value),
            maxLines: 3,
            decoration: inputDecoration(''),
          ),
        ],
      ),
    );
  }

  void criarOcorrencia() {
    final tituloController = TextEditingController();
    final localController = TextEditingController();
    final descricaoController = TextEditingController();

    String status = 'Em análise';
    String prioridade = 'Baixa';
    File? imagem;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              child: Container(
                width: 700,
                padding: const EdgeInsets.all(28),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextField(
                        controller: tituloController,
                        decoration: inputDecoration('Título'),
                      ),
                      const SizedBox(height: 18),
                      TextField(
                        controller: localController,
                        decoration: inputDecoration('Local'),
                      ),
                      const SizedBox(height: 18),
                      TextField(
                        controller: descricaoController,
                        maxLines: 5,
                        decoration: inputDecoration('Descrição'),
                      ),
                      const SizedBox(height: 18),
                      DropdownButtonFormField<String>(
                        initialValue: status,
                        decoration: inputDecoration('Status'),
                        items: ['Em análise', 'Em andamento', 'Finalizado']
                            .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)),
                            )
                            .toList(),
                        onChanged: (v) {
                          setStateDialog(() {
                            status = v!;
                          });
                        },
                      ),
                      const SizedBox(height: 18),
                      DropdownButtonFormField<String>(
                        initialValue: prioridade,
                        decoration: inputDecoration('Prioridade'),
                        items: ['Baixa', 'Média', 'Alta']
                            .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)),
                            )
                            .toList(),
                        onChanged: (v) {
                          setStateDialog(() {
                            prioridade = v!;
                          });
                        },
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final result = await FilePicker.platform.pickFiles(
                              type: FileType.image,
                            );

                            if (result != null) {
                              setStateDialog(() {
                                imagem = File(result.files.single.path!);
                              });
                            }
                          },
                          icon: const Icon(Icons.image_outlined),
                          label: Text(
                            imagem == null
                                ? 'Selecionar Imagem'
                                : imagem!.path.split('/').last,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xffa61d2d),
                          ),
                          onPressed: () {
                            setState(() {
                              final newItem = {
                                'titulo': tituloController.text,
                                'local': localController.text,
                                'descricao': descricaoController.text,
                                'status': status,
                                'prioridade': prioridade,
                                'data': DateFormat(
                                  'dd/MM/yyyy',
                                ).format(DateTime.now()),
                                'imagem': imagem,
                              };

                              widget.ocorrencias.insert(0, newItem);
                              _searchOcorrencias(pesquisaController.text);
                            });

                            Navigator.pop(context);
                          },
                          child: const Text('Criar Ocorrência'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

InputDecoration inputDecoration(String hint) {
  return InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: Color(0xffe8e8e8)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: Color(0xffe8e8e8)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: Color(0xffa61d2d)),
    ),
  );
}
class MainScreen extends StatefulWidget {
  const MainScreen({super.key, required this.isAdmin});
  final bool isAdmin;

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  late List<Widget> _pages;
   final List<Map<String, dynamic>> ocorrencias = [
    {
      'titulo': 'Servidor Offline',
      'local': 'Datacenter Principal',
      'status': 'Em andamento',
      'prioridade': 'Alta',
      'descricao': 'Servidor principal sem comunicação.',
      'data': '18/05/2026',
      'imagem': null,
    },
    {
      'titulo': 'Câmera com Falha',
      'local': 'Entrada Norte',
      'status': 'Em análise',
      'prioridade': 'Intermediária',
      'descricao': 'Imagem travando.',
      'data': '17/05/2026',
      'imagem': null,
    },
  ];
  @override
void initState() {
  super.initState();
  _pages = [
    DashboardPage(isAdmin: widget.isAdmin, ocorrencias: ocorrencias),
    SearchPage(ocorrencias: ocorrencias),
    TeamPage(isAdmin: widget.isAdmin),
    ProfilePage(isAdmin: widget.isAdmin),
  ];
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
  floatingActionButton: FloatingActionButton(
    backgroundColor: const Color(0xffa61d2d),
    onPressed:() {},  
    child: const Icon(Icons.add),
  ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xffa61d2d),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Buscar'),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Equipe'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}