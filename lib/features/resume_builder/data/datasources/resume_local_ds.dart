import '../../../../core/error/exceptions.dart';
import '../../../../core/storage/key_value_store.dart';
import '../models/resume_draft_dto.dart';

/// Local data source for resume drafts
abstract class ResumeLocalDataSource {
  /// Creates a new draft and saves it locally
  Future<ResumeDraftDto> createDraft(ResumeDraftDto draft);

  /// Gets a draft by ID
  Future<ResumeDraftDto?> getDraft(String draftId);

  /// Gets all saved drafts
  Future<List<ResumeDraftDto>> getAllDrafts();

  /// Saves/updates a draft
  Future<ResumeDraftDto> saveDraft(ResumeDraftDto draft);

  /// Deletes a draft
  Future<void> deleteDraft(String draftId);

  /// Checks if a draft exists
  Future<bool> draftExists(String draftId);
}

/// Implementation of ResumeLocalDataSource using KeyValueStore
class ResumeLocalDataSourceImpl implements ResumeLocalDataSource {
  final KeyValueStore _store;

  static const String _draftsKey = 'resume_drafts';
  static const String _draftIdsKey = 'resume_draft_ids';

  ResumeLocalDataSourceImpl(this._store);

  @override
  Future<ResumeDraftDto> createDraft(ResumeDraftDto draft) async {
    try {
      // Get existing draft IDs
      final ids = await _getDraftIds();
      ids.add(draft.id);

      // Save draft IDs list
      await _store.setStringList(_draftIdsKey, ids.toList());

      // Save the draft
      await _store.setJson(_getDraftKey(draft.id), draft.toJson());

      return draft;
    } catch (e) {
      throw CacheException(
        message: 'Failed to create draft',
        originalError: e,
      );
    }
  }

  @override
  Future<ResumeDraftDto?> getDraft(String draftId) async {
    try {
      final json = await _store.getJson(_getDraftKey(draftId));
      if (json == null) return null;
      return ResumeDraftDto.fromJson(json);
    } catch (e) {
      throw CacheException(
        message: 'Failed to get draft',
        originalError: e,
      );
    }
  }

  @override
  Future<List<ResumeDraftDto>> getAllDrafts() async {
    try {
      final ids = await _getDraftIds();
      final drafts = <ResumeDraftDto>[];

      for (final id in ids) {
        final draft = await getDraft(id);
        if (draft != null) {
          drafts.add(draft);
        }
      }

      // Sort by updatedAt descending
      drafts.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

      return drafts;
    } catch (e) {
      throw CacheException(
        message: 'Failed to get all drafts',
        originalError: e,
      );
    }
  }

  @override
  Future<ResumeDraftDto> saveDraft(ResumeDraftDto draft) async {
    try {
      // Ensure the draft ID is in the list
      final ids = await _getDraftIds();
      if (!ids.contains(draft.id)) {
        ids.add(draft.id);
        await _store.setStringList(_draftIdsKey, ids.toList());
      }

      // Save the draft
      await _store.setJson(_getDraftKey(draft.id), draft.toJson());

      return draft;
    } catch (e) {
      throw CacheException(
        message: 'Failed to save draft',
        originalError: e,
      );
    }
  }

  @override
  Future<void> deleteDraft(String draftId) async {
    try {
      // Remove from draft IDs list
      final ids = await _getDraftIds();
      ids.remove(draftId);
      await _store.setStringList(_draftIdsKey, ids.toList());

      // Remove the draft data
      await _store.remove(_getDraftKey(draftId));
    } catch (e) {
      throw CacheException(
        message: 'Failed to delete draft',
        originalError: e,
      );
    }
  }

  @override
  Future<bool> draftExists(String draftId) async {
    final ids = await _getDraftIds();
    return ids.contains(draftId);
  }

  String _getDraftKey(String draftId) => '${_draftsKey}_$draftId';

  Future<Set<String>> _getDraftIds() async {
    final list = await _store.getStringList(_draftIdsKey);
    return list?.toSet() ?? {};
  }
}

