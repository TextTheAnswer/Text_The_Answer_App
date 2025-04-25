import 'package:flutter/material.dart';
import 'package:text_the_answer/config/colors.dart';
import 'package:text_the_answer/widgets/app_bar/custom_app_bar.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: CustomAppBar(
          showBackArrow: true,
          title: Text('Help Center'),
          bottom: TabBar(
            indicatorColor: AppColors.buttonPrimary,
            indicatorSize: TabBarIndicatorSize.tab,
            labelStyle: TextStyle(color: AppColors.buttonPrimary),
            dividerHeight: 2,
            indicatorWeight: 3,

            tabs: [Tab(child: Text('FAQ')), Tab(child: Text('Contact Us'))],
          ),
        ),
        body: TabBarView(children: [FAQContent(), ContactUsContent()]),
      ),
    );
  }
}

class FAQContent extends StatelessWidget {
  const FAQContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          //TODO: Implement FAQContent
        ],
      ),
    );
  }
}

class ContactUsContent extends StatelessWidget {
  const ContactUsContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          //TODO: Implement Contact Us
        ],
      ),
    );
  }
}
