import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/question.dart';
import '../state/survey_controller.dart';
import '../theme.dart';
import '../widgets/background_scaffold.dart';
import '../widgets/nps_selector.dart';
import '../widgets/option_tile.dart';
import '../widgets/progress_indicator.dart';
import '../widgets/scale_selector.dart';
import 'thank_you_screen.dart';

class QuestionScreen extends StatefulWidget {
  const QuestionScreen({super.key});

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  final TextEditingController _openTextController = TextEditingController();
  String _openTextQuestionId = '';
  bool _submitting = false;

  @override
  void dispose() {
    _openTextController.dispose();
    super.dispose();
  }

  Future<void> _goNextOrSubmit() async {
    final ctrl = context.read<SurveyController>();
    if (ctrl.isLast) {
      if (_submitting) return;
      setState(() => _submitting = true);
      try {
        await ctrl.submit();
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const ThankYouScreen()),
        );
      } catch (e) {
        if (!mounted) return;
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error guardando: $e')),
        );
      }
    } else {
      ctrl.next();
    }
  }

  void _handleSingleChoice(String value) {
    final ctrl = context.read<SurveyController>();
    ctrl.setAnswer(ctrl.current.id, value);
    _goNextOrSubmit();
  }

  void _handleScale(int value) {
    final ctrl = context.read<SurveyController>();
    ctrl.setAnswer(ctrl.current.id, value);
    _goNextOrSubmit();
  }

  void _handleNps(int value) {
    final ctrl = context.read<SurveyController>();
    ctrl.setAnswer(ctrl.current.id, value);
    _goNextOrSubmit();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<SurveyController>();
    final q = ctrl.current;

    // Sync open-text controller when changing questions.
    if (q.type == QuestionType.openText && _openTextQuestionId != q.id) {
      _openTextQuestionId = q.id;
      final stored = ctrl.answerFor(q.id);
      _openTextController.text = stored is String ? stored : '';
    }

    return BackgroundScaffold(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SurveyProgressIndicator(current: ctrl.index, total: ctrl.total),
            const SizedBox(height: 24),
            Text(
              q.section.toUpperCase(),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
                color: AppColors.accent.withValues(alpha: 0.9),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              q.text,
              style: const TextStyle(
                fontSize: 38,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                height: 1.2,
                shadows: [
                  Shadow(
                    color: Colors.black54,
                    offset: Offset(0, 2),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Expanded(child: _buildBody(ctrl, q)),
            const SizedBox(height: 12),
            _buildFooter(ctrl, q),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(SurveyController ctrl, Question q) {
    switch (q.type) {
      case QuestionType.singleChoice:
        return _SingleChoiceBody(
          question: q,
          value: ctrl.answerFor(q.id) as String?,
          onSelect: _handleSingleChoice,
        );
      case QuestionType.multiChoice:
        return _MultiChoiceBody(
          question: q,
          values: ctrl.multiSelection(q.id),
          onToggle: (opt) => ctrl.toggleMulti(q.id, opt),
        );
      case QuestionType.scale1to5:
        return Center(
          child: ScaleSelector(
            value: ctrl.answerFor(q.id) as int?,
            labels: q.options,
            lowLabel: q.lowLabel,
            highLabel: q.highLabel,
            onSelect: _handleScale,
          ),
        );
      case QuestionType.nps0to10:
        return Center(
          child: NpsSelector(
            value: ctrl.answerFor(q.id) as int?,
            lowLabel: q.lowLabel,
            highLabel: q.highLabel,
            onSelect: _handleNps,
          ),
        );
      case QuestionType.openText:
        return _OpenTextBody(
          controller: _openTextController,
          onChanged: (v) => ctrl.setAnswer(q.id, v),
        );
    }
  }

  Widget _buildFooter(SurveyController ctrl, Question q) {
    final canGoBack = !ctrl.isFirst;
    Widget? actionButton;

    if (q.type == QuestionType.multiChoice) {
      final hasSelection = ctrl.multiSelection(q.id).isNotEmpty;
      actionButton = ElevatedButton.icon(
        onPressed: hasSelection ? _goNextOrSubmit : null,
        icon: const Icon(Icons.arrow_forward_rounded, size: 32),
        label: const Text('Avanzar'),
      );
    } else if (q.type == QuestionType.openText) {
      final text = _openTextController.text.trim();
      final enabled = text.isNotEmpty && !_submitting;
      actionButton = ElevatedButton.icon(
        onPressed: enabled ? _goNextOrSubmit : null,
        icon: _submitting
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.check_circle_outline, size: 32),
        label: Text(_submitting ? 'Guardando...' : 'Finalizar'),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (canGoBack)
          TextButton.icon(
            onPressed: _submitting
                ? null
                : () => context.read<SurveyController>().previous(),
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            label: const Text(
              'Atrás',
              style: TextStyle(color: Colors.white, fontSize: 22),
            ),
          )
        else
          const SizedBox.shrink(),
        ?actionButton,
      ],
    );
  }
}

class _SingleChoiceBody extends StatelessWidget {
  final Question question;
  final String? value;
  final ValueChanged<String> onSelect;

  const _SingleChoiceBody({
    required this.question,
    required this.value,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.only(top: 4, bottom: 12),
      itemCount: question.options.length,
      separatorBuilder: (_, _) => const SizedBox(height: 14),
      itemBuilder: (_, i) {
        final opt = question.options[i];
        return OptionTile(
          label: opt,
          selected: value == opt,
          onTap: () => onSelect(opt),
        );
      },
    );
  }
}

class _MultiChoiceBody extends StatelessWidget {
  final Question question;
  final List<String> values;
  final ValueChanged<String> onToggle;

  const _MultiChoiceBody({
    required this.question,
    required this.values,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.only(top: 4, bottom: 12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        mainAxisExtent: 90,
      ),
      itemCount: question.options.length,
      itemBuilder: (_, i) {
        final opt = question.options[i];
        return OptionTile(
          label: opt,
          selected: values.contains(opt),
          multi: true,
          onTap: () => onToggle(opt),
        );
      },
    );
  }
}

class _OpenTextBody extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _OpenTextBody({
    required this.controller,
    required this.onChanged,
  });

  @override
  State<_OpenTextBody> createState() => _OpenTextBodyState();
}

class _OpenTextBodyState extends State<_OpenTextBody> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChange);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChange);
    super.dispose();
  }

  void _onTextChange() {
    widget.onChanged(widget.controller.text);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      minLines: 6,
      maxLines: 10,
      textInputAction: TextInputAction.newline,
      style: const TextStyle(fontSize: 24, color: Colors.white),
      decoration: const InputDecoration(
        hintText: 'Escribe aquí tu idea o comentario...',
      ),
    );
  }
}
