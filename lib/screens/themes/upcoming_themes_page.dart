import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:text_the_answer/blocs/category/category_bloc.dart';
import 'package:text_the_answer/blocs/category/category_event.dart';
import 'package:text_the_answer/blocs/category/category_state.dart';
import 'package:text_the_answer/widgets/error_widget.dart';
import 'package:text_the_answer/widgets/loading_widget.dart';

class UpcomingThemesPage extends StatefulWidget {
  const UpcomingThemesPage({Key? key}) : super(key: key);

  @override
  State<UpcomingThemesPage> createState() => _UpcomingThemesPageState();
}

class _UpcomingThemesPageState extends State<UpcomingThemesPage> {
  @override
  void initState() {
    super.initState();
    context.read<CategoryBloc>().add(FetchUpcomingThemesEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upcoming Themes'),
      ),
      body: BlocBuilder<CategoryBloc, CategoryState>(
        builder: (context, state) {
          if (state is ThemeLoading) {
            return const LoadingWidget();
          } else if (state is UpcomingThemesLoaded) {
            return _buildUpcomingThemesList(state.themes);
          } else if (state is ThemeError) {
            return CustomErrorWidget(message: state.message);
          } else {
            return const Center(
              child: Text('No upcoming themes found'),
            );
          }
        },
      ),
    );
  }

  Widget _buildUpcomingThemesList(List<Map<String, dynamic>> themes) {
    if (themes.isEmpty) {
      return const Center(
        child: Text(
          'No upcoming themes available',
          style: TextStyle(fontSize: 18.0),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: themes.length,
      itemBuilder: (context, index) {
        final theme = themes[index];
        final date = theme['date'] != null
            ? DateTime.parse(theme['date'].toString())
            : DateTime.now().add(Duration(days: index + 1));
        
        return Card(
          elevation: 4.0,
          margin: const EdgeInsets.only(bottom: 16.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      theme['name'] ?? 'Unknown Theme',
                      style: const TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 6.0,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: Text(
                        '${date.day}/${date.month}/${date.year}',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8.0),
                Text(
                  theme['description'] ?? 'No description available',
                  style: const TextStyle(fontSize: 16.0),
                ),
                const SizedBox(height: 8.0),
                Text(
                  'Category: ${theme['categoryName'] ?? 'General'}',
                  style: const TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 16.0),
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Theme.of(context).primaryColor,
                      size: 16.0,
                    ),
                    const SizedBox(width: 8.0),
                    const Expanded(
                      child: Text(
                        'Premium feature: Preview upcoming daily quiz themes',
                        style: TextStyle(
                          fontSize: 12.0,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
