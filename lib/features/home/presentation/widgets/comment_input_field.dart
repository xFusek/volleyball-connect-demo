import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CommentInputField extends StatefulWidget {
  final Future<void> Function(String content) onSend;

  const CommentInputField({super.key, required this.onSend});

  @override
  State<CommentInputField> createState() => _CommentInputFieldState();
}

class _CommentInputFieldState extends State<CommentInputField> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isSending = false;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _handleSend() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() => _isSending = true);

    try {
      await widget.onSend(text);
      _controller.clear();
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                minLines: 1,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Write a comment...',
                  hintStyle: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.grey.shade500,
                  ),
                  isDense: true,
                  filled: true,
                  fillColor: const Color(0xFFF8F9FA),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 10.h,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.r),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.r),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.r),
                    borderSide: const BorderSide(color: Color(0xFFC84E4E)),
                  ),
                ),
              ),
            ),
            SizedBox(width: 8.w),
            IconButton(
              icon: _isSending
                  ? SizedBox(
                      width: 18.sp,
                      height: 18.sp,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFFC84E4E),
                      ),
                    )
                  : Icon(
                      Icons.send,
                      color: const Color(0xFFC84E4E),
                      size: 22.sp,
                    ),
              onPressed: _isSending ? null : _handleSend,
            ),
          ],
        ),
      ),
    );
  }
}
