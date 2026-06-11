import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'firebase_options.dart';
import 'pages/iniciar_page.dart';
import 'pages/profile_page.dart';
import 'pages/search_page.dart';
import 'pages/team_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final senhaController = TextEditingController();
  bool _carregando = false;
  String? _erro;

  Future<void> _login() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: senhaController.text.trim(),
      );

      final doc = await FirebaseFirestore.instance
          .collection('usuarios')
          .where('email', isEqualTo: emailController.text.trim())
          .get();

      if (doc.docs.isEmpty) {
        setState(() => _erro = 'Usuário sem cadastro no Firestore.');
        return;
      }

      final userData = doc.docs.first.data();
      final tipo = userData['tipo'] as String? ?? 'funcionario';
      final isAdmin = tipo == 'admin';
      final setor = (userData['setor'] as String? ?? '')
        .trim()
        .toLowerCase();

      print('SETOR DO USUARIO: $setor');


      if (mounted) {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (_) => MainScreen(
        isAdmin: isAdmin,
        setor: setor,
      ),
    ),
  );
}
      
    } on FirebaseAuthException catch (e) {
      setState(() {
        _erro = e.code == 'user-not-found'
            ? 'Usuário não encontrado.'
            : e.code == 'wrong-password'
                ? 'Senha incorreta.'
                : 'Erro ao fazer login. Tente novamente.';
      });
    } finally {
      if (mounted) {
        setState(() => _carregando = false);
      }
    }
  }

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
                if (_erro != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _erro!,
                    style: const TextStyle(color: Colors.red, fontSize: 13),
                  ),
                ],
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
                    onPressed: _carregando ? null : _login,
                    child: _carregando
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Entrar'),
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
  final String setor;
  final List<Map<String, dynamic>> ocorrencias;

  const DashboardPage({
    super.key,
    required this.isAdmin,
    required this.setor,
    required this.ocorrencias,
  });

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final pesquisaController = TextEditingController();
  late List<Map<String, dynamic>> filteredOcorrencias;
  List<Map<String, dynamic>> categoriasFirebase = [];

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

  Future<void> carregarCategorias() async {
    final snapshot = await FirebaseFirestore.instance.collection('categorias').get();

    categoriasFirebase = snapshot.docs.map((doc) {
      return {
        'id': doc.id,
        ...doc.data(),
      };
    }).toList();
  }

  String _prioridadeTexto(double value) {
    if (value < 0.5) return 'Baixa';
    if (value < 1.5) return 'Média';
    return 'Alta';
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

    return Stack(
      children: [
        SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1500),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          'Report+',
                          style: GoogleFonts.inter(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xffa61d2d),
                          ),
                        ),
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
                      ],
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: pesquisaController,
                      onChanged: _searchOcorrencias,
                      decoration: inputDecoration('Pesquisar ocorrência...').copyWith(
                        prefixIcon: IconButton(
                          onPressed: () => _searchOcorrencias(pesquisaController.text),
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
                          const SizedBox(width: 16),
                          Expanded(flex: 3, child: buildLista()),
                        ],
                      )
                    else if (isTablet)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: buildCardsGrid(2)),
                            const SizedBox(height: 16),
                            Expanded(child: buildLista()),
                          ],
                        ),
                      )
                    else
                      Expanded(
                        child: Column(
                          children: [
                            buildCardsGrid(2),
                            const SizedBox(height: 16),
                            Expanded(child: buildLista()),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (!widget.isAdmin)
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              backgroundColor: const Color(0xffa61d2d),
              onPressed: criarOcorrencia,
              child: const Icon(Icons.add),
            ),
          ),
      ],
    );
  }

  Widget buildCardsGrid(int crossAxisCount) {
    final width = MediaQuery.of(context).size.width;
    final aspectRatio = width < 400 ? 1.0 : width < 700 ? 1.4 : 1.8;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: aspectRatio,
      children: [
        estatisticaCard('Ocorrências', widget.ocorrencias.length.toString()),
        estatisticaCard(
          'Alta Prioridade',
          widget.ocorrencias.where((e) => e['prioridade'] == 'Alta').length.toString(),
        ),
        estatisticaCard(
          'Em Andamento',
          widget.ocorrencias.where((e) => e['status'] == 'Em andamento').length.toString(),
        ),
        estatisticaCard(
          'Finalizadas',
          widget.ocorrencias.where((e) => e['status'] == 'Finalizado').length.toString(),
        ),
      ],
    );
  }

  Widget estatisticaCard(String titulo, String valor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xffe8e8e8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(titulo, style: const TextStyle(color: Color(0xff7a7a7a))),
          const SizedBox(height: 8),
          Text(
            valor,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget buildLista() {
    return Container(
      padding: const EdgeInsets.all(12),
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
            child: filteredOcorrencias.isEmpty
                ? const Center(child: Text('Nenhuma ocorrência encontrada.'))
                : ListView.separated(
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
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xfff8f8f8),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            if (item['imagem'] != null || item['imagemUrl'] != null)
              Container(
                width: 90,
                height: 90,
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.grey.shade200,
                ),
                clipBehavior: Clip.hardEdge,
                child: item['imagem'] != null
                    ? Image.file(
                        item['imagem'] as File,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, color: Colors.grey),
                      )
                    : Image.network(
                        item['imagemUrl'] as String,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, color: Colors.grey),
                      ),
              ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['titulo']?.toString() ?? '',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item['local']?.toString() ?? '',
                    style: const TextStyle(color: Color(0xff7a7a7a)),
                  ),
                  const SizedBox(height: 8),
                  Text('${item['status'] ?? ''} • ${item['prioridade'] ?? ''}'),
                ],
              ),
            ),
            const SizedBox(width: 16),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: const Color(0xffa61d2d)),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          child: Container(
            width: 600,
            padding: const EdgeInsets.all(28),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['titulo']?.toString() ?? '',
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  buildInfoField('Local', item['local']?.toString() ?? ''),
                  buildInfoField('Descrição', item['descricao']?.toString() ?? ''),
                  buildInfoField('Status', item['status']?.toString() ?? ''),
                  buildInfoField('Prioridade', item['prioridade']?.toString() ?? ''),
                  buildInfoField('Data', item['data']?.toString() ?? ''),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: FilledButton(
                      style: FilledButton.styleFrom(backgroundColor: const Color(0xffa61d2d)),
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

  void atualizarAndamento(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['titulo']?.toString() ?? '',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text('Atualizar andamento', style: TextStyle(color: Color(0xff7a7a7a))),
                const SizedBox(height: 24),
                ...['Aberta', 'Em análise', 'Em andamento', 'Resolvido', 'Finalizado'].map(
                  (status) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          side: BorderSide(
                            color: item['status'] == status ? const Color(0xffa61d2d) : const Color(0xffe8e8e8),
                          ),
                          foregroundColor: item['status'] == status ? const Color(0xffa61d2d) : Colors.black,
                        ),
                        onPressed: () async {
                          await FirebaseFirestore.instance
                              .collection('ocorrencias')
                              .doc(item['id'])
                              .update({'status': status});

                          if (mounted) {
                            setState(() {
                              item['status'] = status;
                              _searchOcorrencias(pesquisaController.text);
                            });
                          }

                          if (context.mounted) Navigator.pop(context);
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
            readOnly: true,
          ),
        ],
      ),
    );
  }

  Future<void> criarOcorrencia() async {
    await carregarCategorias();

    if (categoriasFirebase.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nenhuma categoria cadastrada no Firebase.')),
      );
      return;
    }

    final tituloController = TextEditingController();
    final localController = TextEditingController();
    final descricaoController = TextEditingController();

    String status = 'Em análise';
    File? imagem;
    double prioridadeValue = 0;
    String categoria = categoriasFirebase.first['id'].toString();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
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
                        value: categoria,
                        decoration: inputDecoration('Categoria'),
                        items: categoriasFirebase.map((cat) {
                          return DropdownMenuItem<String>(
                            value: cat['id'].toString(),
                            child: Text(cat['nome'].toString()),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          setStateDialog(() {
                            categoria = value;
                          });
                        },
                      ),
                      const SizedBox(height: 18),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Prioridade: ${_prioridadeTexto(prioridadeValue)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Slider(
                        min: 0,
                        max: 2,
                        divisions: 2,
                        value: prioridadeValue,
                        label: _prioridadeTexto(prioridadeValue),
                        onChanged: (value) {
                          setStateDialog(() {
                            prioridadeValue = value;
                          });
                        },
                      ),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [Text('Baixa'), Text('Média'), Text('Alta')],
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final result = await FilePicker.platform.pickFiles(type: FileType.image);
                            if (result != null && result.files.single.path != null) {
                              setStateDialog(() {
                                imagem = File(result.files.single.path!);
                              });
                            }
                          },
                          icon: const Icon(Icons.image_outlined),
                          label: Text(
                            imagem == null ? 'Importar imagem' : imagem!.path.split(Platform.pathSeparator).last,
                          ),
                        ),
                      ),
                      if (imagem != null) ...[
                        const SizedBox(height: 18),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Image.file(
                            imagem!,
                            width: double.infinity,
                            height: 190,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: FilledButton(
                          style: FilledButton.styleFrom(backgroundColor: const Color(0xffa61d2d)),
                          onPressed: () async {
                            final categoriaSelecionada = categoriasFirebase.firstWhere(
                              (c) => c['id'].toString() == categoria,
                            );

                            final newItem = {
                              'titulo': tituloController.text.trim(),
                              'local': localController.text.trim(),
                              'descricao': descricaoController.text.trim(),
                              'categoria': categoriaSelecionada['nome'],
                              'setor': categoriaSelecionada['setor'],
                              'status': status,
                              'prioridade': _prioridadeTexto(prioridadeValue),
                              'data': DateFormat('dd/MM/yyyy').format(DateTime.now()),
                              'imagem': null,
                            };
                            final docRef = await FirebaseFirestore.instance
                                .collection('ocorrencias')
                                .add(newItem);

                            final itemComId = {
                              'id': docRef.id,
                              ...newItem,
                            };

                            if (!mounted) return;

                             setState(() {
                              if (widget.isAdmin || itemComId['setor'] == widget.setor) {
                                widget.ocorrencias.add(itemComId);
                              }

                              filteredOcorrencias = List.from(widget.ocorrencias);
                            });

                            Future.delayed(const Duration(milliseconds: 100), () {
                              if (context.mounted) {
                                Navigator.of(context).pop();
                              }
                            });
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

  void _abrirSobre() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
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
                    child: Text('Sistema de reporte de problemas', style: TextStyle(color: Color(0xff7a7a7a))),
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 12),
                  _sobreItem('Disciplina', 'Desenvolvimento de Software'),
                  _sobreItem('Programa', 'Fábrica de Softwares'),
                  _sobreItem(
                    'Professores Responsáveis',
                    'Prof. Dr. Elvio Gilberto da Silva\nProf. Me. Luis Felipe Grael Tinós\nProfessora Esp. Camila Floret Pelizon',
                  ),
                  _sobreItem(
                    'Grupo 14',
                    'Bruno Mansano dos Passos\nDiego Costanzo Galvão\nIsabela Eugênia Teixeira Ferraz de Oliveira\nJoão Igor Alves Oros Reis\nLucas Augusto Martins\n\nCiência da Computação (CC)',
                  ),
                  _sobreItem(
                    'Sobre o App',
                    'Aplicativo desenvolvido para facilitar o reporte de problemas na empresa, promovendo uma comunicação colaborativa entre funcionários e administradores.',
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xffa61d2d),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
          Text(valor, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({
    super.key,
    required this.isAdmin,
    required this.setor,
  });

  final bool isAdmin;
  final String setor;

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  List<Widget> _pages = [];
  List<Map<String, dynamic>> ocorrencias = [];

  @override
  void initState() {
    super.initState();
    inicializar();
  }
    Future<void> carregarOcorrencias() async {
      Query<Map<String, dynamic>> query =
          FirebaseFirestore.instance.collection('ocorrencias');
          print('BUSCANDO OCORRENCIAS DO SETOR: ${widget.setor}');


      if (!widget.isAdmin) {
        query = query.where('setor', isEqualTo: widget.setor);
      }

      final snapshot = await query.get();
       print('OCORRENCIAS ENCONTRADAS: ${snapshot.docs.length}');

      ocorrencias = snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data(),
        };
      }).toList();
    }

  Future<void> inicializar() async {
    await carregarOcorrencias();

    if (!mounted) return;

    setState(() {
      _pages = [
        DashboardPage(
          isAdmin: widget.isAdmin,
          setor: widget.setor,
          ocorrencias: ocorrencias,
        ),
        SearchPage(ocorrencias: ocorrencias),
        TeamPage(isAdmin: widget.isAdmin),
        ProfilePage(isAdmin: widget.isAdmin),
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_pages.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
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
