import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/models/mpi_models.dart';
import 'mpi_shareable_card.dart';

// ─── Palette ──────────────────────────────────────────────────────────────────
const _kBg        = Color(0xFF1E0F3C);
const _kSurface   = Color(0xFF2A1850);
const _kDeep      = Color(0xFF150A28);
const _kBorder    = Color(0xFF3d2070);
const _kActiveBg  = Color(0x1A6B35C8);
const _kAccent    = Color(0xFF6B35C8);
const _kAccentBdr = Color(0xFF6B35C8);
const _kLight     = Color(0xFFA67CF0);
const _kPink      = Color(0xFFFF6B9D);
const _kMuted     = Color(0xFF9a85c8);

void showMpiShareModal(BuildContext context, MpiResult result) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _MpiShareModal(result: result),
  );
}

class _MpiShareModal extends StatefulWidget {
  final MpiResult result;
  const _MpiShareModal({required this.result});

  @override
  State<_MpiShareModal> createState() => _MpiShareModalState();
}

class _MpiShareModalState extends State<_MpiShareModal> {
  ShareFormat _format = ShareFormat.square;
  final _screenshotController = ScreenshotController();
  final _repaintKey = GlobalKey();
  bool _isCopied = false;
  String? _capturingPlatform; // tracks which button is capturing

  String get _shareUrl => 'mindscore.app/result/${widget.result.shareToken}';

  Future<Uint8List?> _captureCard() async {
    try {
      return await _screenshotController.capture(pixelRatio: 3.0);
    } catch (_) {
      return null;
    }
  }

  Future<void> _shareToPlaftorm(String platform) async {
    setState(() => _capturingPlatform = platform);
    try {
      final bytes = await _captureCard();
      if (bytes == null) return;

      if (kIsWeb) {
        _webDownload(bytes, 'mindscore_mpi_result.png');
        return;
      }

      await Share.shareXFiles(
        [XFile.fromData(bytes, name: 'mindscore_mpi_result.png', mimeType: 'image/png')],
        text: 'I am ${widget.result.typeName} on the MindScore MPI. '
            'Discover yours at mindscore.app',
      );
    } finally {
      if (mounted) setState(() => _capturingPlatform = null);
    }
  }

  Future<void> _saveAsImage() async {
    setState(() => _capturingPlatform = 'save');
    try {
      final bytes = await _captureCard();
      if (bytes == null) return;

      if (kIsWeb) {
        _webDownload(bytes, 'mindscore_mpi_result.png');
        return;
      }

      await Share.shareXFiles(
        [XFile.fromData(bytes, name: 'mindscore_mpi_result.png', mimeType: 'image/png')],
      );
    } finally {
      if (mounted) setState(() => _capturingPlatform = null);
    }
  }

  void _webDownload(Uint8List bytes, String filename) {
    // Web fallback: copy share URL to clipboard
    Clipboard.setData(ClipboardData(text: _shareUrl));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share link copied (image download not supported in browser preview)')),
    );
  }

  Future<void> _copyLink() async {
    await Clipboard.setData(ClipboardData(text: _shareUrl));
    setState(() => _isCopied = true);
    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) setState(() => _isCopied = false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: _kBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: _kBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Share your MPI result',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: _kSurface,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, size: 14, color: Colors.white70),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Format tabs
            Row(
              children: ShareFormat.values.map((f) {
                final isActive = f == _format;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _format = f),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: isActive ? _kActiveBg : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isActive ? _kAccentBdr : _kBorder,
                          width: isActive ? 1 : 0.5,
                        ),
                      ),
                      child: Text(
                        _formatLabel(f),
                        style: TextStyle(
                          fontSize: 12,
                          color: isActive ? _kLight : _kMuted,
                          fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Card preview
            Center(
              child: Container(
                color: _kDeep,
                padding: const EdgeInsets.all(12),
                child: Screenshot(
                  controller: _screenshotController,
                  child: MpiShareableCard(
                    result: widget.result,
                    format: _format,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Social share row
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _SocialButton(
                  platform: 'Instagram',
                  color: const Color(0xFFE1306C),
                  icon: '📸',
                  isCapturing: _capturingPlatform == 'Instagram',
                  onTap: () => _shareToPlaftorm('Instagram'),
                ),
                _SocialButton(
                  platform: 'LinkedIn',
                  color: const Color(0xFF0077B5),
                  icon: '💼',
                  isCapturing: _capturingPlatform == 'LinkedIn',
                  onTap: () => _shareToPlaftorm('LinkedIn'),
                ),
                _SocialButton(
                  platform: 'WhatsApp',
                  color: const Color(0xFF25D366),
                  icon: '💬',
                  isCapturing: _capturingPlatform == 'WhatsApp',
                  onTap: () => _shareToPlaftorm('WhatsApp'),
                ),
                _SocialButton(
                  platform: 'X',
                  color: Colors.white,
                  icon: '✖',
                  isCapturing: _capturingPlatform == 'X',
                  onTap: () => _shareToPlaftorm('X'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Copy link row
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: _kDeep,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _kBorder, width: 0.5),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _shareUrl,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        color: _kMuted,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _copyLink,
                    child: Text(
                      _isCopied ? 'Copied!' : 'Copy link',
                      style: TextStyle(
                        fontSize: 12,
                        color: _isCopied ? Colors.green : _kLight,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: _capturingPlatform == 'save'
                      ? _LoadingButton(color: _kPink)
                      : ElevatedButton(
                          onPressed: _saveAsImage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _kPink,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Save as image',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _kLight,
                      side: const BorderSide(color: _kBorder),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Download PDF report',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatLabel(ShareFormat f) => switch (f) {
        ShareFormat.square => 'Square (1:1)',
        ShareFormat.story  => 'Story (9:16)',
        ShareFormat.wide   => 'Wide (16:9)',
      };
}

class _SocialButton extends StatelessWidget {
  final String platform;
  final Color color;
  final String icon;
  final bool isCapturing;
  final VoidCallback onTap;

  const _SocialButton({
    required this.platform,
    required this.color,
    required this.icon,
    required this.isCapturing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isCapturing ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF2A1850),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF3d2070), width: 0.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isCapturing)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFFA67CF0),
                ),
              )
            else
              Text(icon, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Text(
              platform,
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingButton extends StatelessWidget {
  final Color color;
  const _LoadingButton({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Center(
        child: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2,
          ),
        ),
      ),
    );
  }
}
