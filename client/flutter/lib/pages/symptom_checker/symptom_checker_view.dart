import 'package:flutter/cupertino.dart';
import 'package:who_app/api/content/schema/symptom_checker_content.dart';
import 'package:who_app/components/dialogs.dart';
import 'package:who_app/pages/symptom_checker/question_pages/yes_no_question_page.dart';
import 'package:who_app/pages/symptom_checker/symptom_checker_model.dart';

/// This view is the container for the series of symptom checker questions.
class SymptomCheckerView extends StatefulWidget {
  @override
  _SymptomCheckerViewState createState() => _SymptomCheckerViewState();
}

class _SymptomCheckerViewState extends State<SymptomCheckerView>
    implements SymptomCheckerPageDelegate {
  final PageController _controller = PageController();
  SymptomCheckerModel _model;
  List<Widget> _pages;

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    await _initModel();
    _modelChanged();
  }

  Future<void> _initModel() async {
    if (_model != null) {
      return;
    }
    // TODO: Reduce this boilerplate
    Locale locale = Localizations.localeOf(context);
    try {
      var content = await SymptomCheckerContent.load(locale);
      await Dialogs.showUpgradeDialogIfNeededFor(context, content);
      _model = SymptomCheckerModel(content);
    } catch (err) {
      print("Error loading content: $err");
    }
    _model.addListener(_modelChanged);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoColors.white,
        middle: Text("Symptom Checker"),
      ),
      child: Container(child: _buildPage(context)),
    );
  }

  Widget _buildPage(BuildContext context) {
    if (_model == null) {
      return _buildMessage("Loading...");
    }
    if (_model.isComplete) {
      return _buildMessage("Complete!");
    }
    if (_model.seekMedicalAttention) {
      return _buildMessage("Seek Medical Attention!");
    }
    return PageView(
        physics: NeverScrollableScrollPhysics(),
        controller: _controller,
        children: _pages ?? []);
  }

  Widget _buildMessage(String text) {
    return Column(
      children: <Widget>[
        Spacer(),
        Center(child: Text(text)),
        Spacer(flex: 3),
      ],
    );
  }

  Widget _viewForPageModel(SymptomCheckerPageModel model) {
    switch (model.question.type) {
      case SymptomCheckerQuestionType.YesNo:
        return YesNoQuestionPage(pageDelegate: this, pageModel: model);
        break;
      case SymptomCheckerQuestionType.ShortListSingleSelection:
        // TODO:
        return Container();
        break;
      case SymptomCheckerQuestionType.ShortListMultipleSelection:
        // TODO:
        return Container();
        break;
      case SymptomCheckerQuestionType.LongListSingleSelection:
        // TODO:
        return Container();
        break;
    }
    throw Exception("can't reach here");
  }

  void _modelChanged() {
    setState(() {
      _pages = _model.pages.map(_viewForPageModel).toList();
    });
    _nextPage();
  }

  Future<void> _nextPage() => _controller.nextPage(
      duration: Duration(milliseconds: 500), curve: Curves.easeInOut);

  //Future<void> _previousPage() => _controller.previousPage(
  //duration: Duration(milliseconds: 500), curve: Curves.easeInOut);

  /// Receive answers from the page and update the model.
  @override
  void answerQuestion(Set<String> answerIds) {
    _model.answerQuestion(answerIds);
  }

  /// Receive back indication from the page and update the model.
  @override
  void goBack() {
    _model.previousQuestion();
  }
}