import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SearchPage extends StatefulWidget {
  final List<Map<String, dynamic>> ocorrencias;
  const SearchPage({super.key, required this.ocorrencias});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
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

  void _search(String query) {
    setState(() {
      final q = query.trim().toLowerCase();
      if (q.isEmpty) {
        filteredOcorrencias = List.from(widget.ocorrencias);
      } else {
        filteredOcorrencias = widget.ocorrencias.where((item) {
          return item['titulo'].toString().toLowerCase().contains(q) ||
              item['local'].toString().toLowerCase().contains(q) ||
              item['status'].toString().toLowerCase().contains(q) ||
              item['prioridade'].toString().toLowerCase().contains(q);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Buscar',
              style: GoogleFonts.inter(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: const Color(0xffa61d2d),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: pesquisaController,
              onChanged: _search,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Pesquisar ocorrência...',
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.search),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
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
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: filteredOcorrencias.isEmpty
                  ? const Center(
                      child: Text(
                        'Nenhuma ocorrência encontrada.',
                        style: TextStyle(color: Color(0xff7a7a7a)),
                      ),
                    )
                  : ListView.separated(
                      itemCount: filteredOcorrencias.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final item = filteredOcorrencias[index];
                        return Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: const Color(0xffe8e8e8)),
                          ),
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
                              const SizedBox(height: 6),
                              Text(
                                item['local'],
                                style: const TextStyle(
                                  color: Color(0xff7a7a7a),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text('${item['status']} • ${item['prioridade']}'),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}