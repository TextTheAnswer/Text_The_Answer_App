import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:text_the_answer/blocs/study_material/study_material_bloc.dart';
import 'package:text_the_answer/blocs/study_material/study_material_event.dart';
import 'package:text_the_answer/blocs/study_material/study_material_state.dart';
import 'package:text_the_answer/models/study_material.dart';
import 'package:text_the_answer/widgets/error_widget.dart';
import 'package:text_the_answer/widgets/loading_widget.dart';
import 'package:text_the_answer/router/routes.dart';

class StudyMaterialsPage extends StatefulWidget {
  const StudyMaterialsPage({Key? key}) : super(key: key);

  @override
  State<StudyMaterialsPage> createState() => _StudyMaterialsPageState();
}

class _StudyMaterialsPageState extends State<StudyMaterialsPage> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _tagsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<StudyMaterialBloc>().add(FetchStudyMaterialsEvent());
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Materials'),
        actions: [
          IconButton(
            icon: const Icon(Icons.emoji_events),
            tooltip: 'Achievements',
            onPressed: () {
              context.go('${AppRoutePath.library}/achievements');
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddMaterialDialog(context),
          ),
        ],
      ),
      body: BlocBuilder<StudyMaterialBloc, StudyMaterialState>(
        builder: (context, state) {
          if (state is StudyMaterialLoading) {
            return const LoadingWidget();
          } else if (state is StudyMaterialsLoaded) {
            return _buildMaterialsList(state.materials);
          } else if (state is StudyMaterialError) {
            return CustomErrorWidget(message: state.message);
          } else if (state is StudyMaterialCreated) {
            // Refresh the list after creating a new material
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.read<StudyMaterialBloc>().add(FetchStudyMaterialsEvent());
            });
            return const LoadingWidget();
          } else if (state is StudyMaterialDeleted) {
            // Refresh the list after deleting a material
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.read<StudyMaterialBloc>().add(FetchStudyMaterialsEvent());
            });
            return const LoadingWidget();
          } else if (state is QuestionsGenerated) {
            return _buildGeneratedQuestions(state.questions);
          } else {
            return const Center(
              child: Text('No study materials found. Add some to get started!'),
            );
          }
        },
      ),
    );
  }

  Widget _buildMaterialsList(List<StudyMaterial> materials) {
    if (materials.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'No study materials found',
              style: TextStyle(fontSize: 18.0),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () => _showAddMaterialDialog(context),
              child: const Text('Add Study Material'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: materials.length,
      itemBuilder: (context, index) {
        final material = materials[index];
        return Card(
          elevation: 4.0,
          margin: const EdgeInsets.only(bottom: 16.0),
          child: ExpansionTile(
            title: Text(
              material.title,
              style: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                'Tags: ${material.tags.join(", ")}',
                style: const TextStyle(
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Content:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text(material.content),
                    const SizedBox(height: 16.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          icon: const Icon(Icons.edit),
                          label: const Text('Edit'),
                          onPressed: () => _showEditMaterialDialog(context, material),
                        ),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.delete),
                          label: const Text('Delete'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          onPressed: () => _confirmDeleteMaterial(context, material),
                        ),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.question_answer),
                          label: const Text('Generate Questions'),
                          onPressed: () {
                            context.read<StudyMaterialBloc>().add(
                                  GenerateQuestionsEvent(material.id),
                                );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGeneratedQuestions(List<Map<String, dynamic>> questions) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Generated Questions',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  context.read<StudyMaterialBloc>().add(FetchStudyMaterialsEvent());
                },
                child: const Text('Back to Materials'),
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          Expanded(
            child: ListView.builder(
              itemCount: questions.length,
              itemBuilder: (context, index) {
                final question = questions[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Question ${index + 1}:',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          question['text'] ?? 'No question text',
                          style: const TextStyle(fontSize: 16.0),
                        ),
                        const SizedBox(height: 16.0),
                        Text(
                          'Answer: ${question['answer'] ?? 'No answer provided'}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          'Difficulty: ${question['difficulty'] ?? 'Medium'}',
                          style: const TextStyle(
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAddMaterialDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Study Material'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'Enter a title for your study material',
                ),
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: 'Content',
                  hintText: 'Enter the content of your study material',
                ),
                maxLines: 5,
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: _tagsController,
                decoration: const InputDecoration(
                  labelText: 'Tags (comma separated)',
                  hintText: 'e.g., math, algebra, equations',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _clearControllers();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_titleController.text.isNotEmpty &&
                  _contentController.text.isNotEmpty) {
                final tags = _tagsController.text
                    .split(',')
                    .map((tag) => tag.trim())
                    .where((tag) => tag.isNotEmpty)
                    .toList();

                context.read<StudyMaterialBloc>().add(
                      CreateStudyMaterialEvent(
                        title: _titleController.text,
                        content: _contentController.text,
                        tags: tags,
                      ),
                    );

                Navigator.of(context).pop();
                _clearControllers();
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditMaterialDialog(BuildContext context, StudyMaterial material) {
    _titleController.text = material.title;
    _contentController.text = material.content;
    _tagsController.text = material.tags.join(', ');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Study Material'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                ),
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: 'Content',
                ),
                maxLines: 5,
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: _tagsController,
                decoration: const InputDecoration(
                  labelText: 'Tags (comma separated)',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _clearControllers();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_titleController.text.isNotEmpty &&
                  _contentController.text.isNotEmpty) {
                final tags = _tagsController.text
                    .split(',')
                    .map((tag) => tag.trim())
                    .where((tag) => tag.isNotEmpty)
                    .toList();

                final updates = {
                  'title': _titleController.text,
                  'content': _contentController.text,
                  'tags': tags,
                };

                context.read<StudyMaterialBloc>().add(
                      UpdateStudyMaterialEvent(
                        id: material.id,
                        updates: updates,
                      ),
                    );

                Navigator.of(context).pop();
                _clearControllers();
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteMaterial(BuildContext context, StudyMaterial material) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Study Material'),
        content: Text(
          'Are you sure you want to delete "${material.title}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () {
              context.read<StudyMaterialBloc>().add(
                    DeleteStudyMaterialEvent(material.id),
                  );
              Navigator.of(context).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _clearControllers() {
    _titleController.clear();
    _contentController.clear();
    _tagsController.clear();
  }
}
