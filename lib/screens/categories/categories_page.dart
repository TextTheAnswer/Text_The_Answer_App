import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:text_the_answer/blocs/category/category_bloc.dart';
import 'package:text_the_answer/blocs/category/category_event.dart';
import 'package:text_the_answer/blocs/category/category_state.dart';
import 'package:text_the_answer/models/category.dart';
import 'package:text_the_answer/widgets/error_widget.dart';
import 'package:text_the_answer/widgets/loading_widget.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({Key? key}) : super(key: key);

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  @override
  void initState() {
    super.initState();
    context.read<CategoryBloc>().add(FetchCategoriesEvent());
    context.read<CategoryBloc>().add(FetchCurrentThemeEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
      ),
      body: BlocBuilder<CategoryBloc, CategoryState>(
        builder: (context, state) {
          if (state is CategoryLoading || state is ThemeLoading) {
            return const LoadingWidget();
          } else if (state is CategoriesLoaded) {
            return _buildCategoriesList(state.categories);
          } else if (state is CategoryError) {
            return CustomErrorWidget(message: state.message);
          } else if (state is CurrentThemeLoaded) {
            return _buildCurrentTheme(state.themeName, state.themeDescription);
          } else {
            return const Center(
              child: Text('Select a category to view questions'),
            );
          }
        },
      ),
    );
  }

  Widget _buildCategoriesList(List<Category> categories) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return Card(
          elevation: 4.0,
          margin: const EdgeInsets.only(bottom: 16.0),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16.0),
            leading: Icon(
              Icons.category,
              color: Theme.of(context).primaryColor,
              size: 36.0,
            ),
            title: Text(
              category.name,
              style: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(category.description),
            ),
            onTap: () {
              context.read<CategoryBloc>().add(FetchCategoryByIdEvent(category.id));
            },
          ),
        );
      },
    );
  }

  Widget _buildCurrentTheme(String themeName, String themeDescription) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Today\'s Theme',
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16.0),
          Card(
            elevation: 4.0,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    themeName,
                    style: const TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    themeDescription,
                    style: const TextStyle(fontSize: 16.0),
                  ),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to daily quiz page
                    },
                    child: const Text('Start Daily Quiz'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24.0),
          const Text(
            'All Categories',
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: () {
              context.read<CategoryBloc>().add(FetchCategoriesEvent());
            },
            child: const Text('View All Categories'),
          ),
        ],
      ),
    );
  }
}
