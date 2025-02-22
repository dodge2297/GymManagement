import 'package:equatable/equatable.dart';
import '../../models/task.dart';
import '../bloc_exports.dart';

part 'tasks_event.dart';
part 'tasks_state.dart';

class TasksBloc extends HydratedBloc<TasksEvent, TasksState> {
  TasksBloc() : super(const TasksState()) {
    on<AddTask>(_onAddTask);
    on<UpdateTask>(_onUpdateTask);
    on<DeleteTask>(_onDeleteTask);
    on<RemoveTask>(_onRemoveTask);
    on<MarkFavoriteOrUnfavoriteTask>(_onMarkFavoriteOrUnfavoriteTask);
    on<EditTask>(_onEditTask);
    on<RestoreTask>(_onRestoreTask);
    on<DeleteAllTasks>(_onDeleteAllTask);
  }

  void _onAddTask(AddTask event, Emitter<TasksState> emit) {}

  void _onUpdateTask(UpdateTask event, Emitter<TasksState> emit) {}

  void _onDeleteTask(DeleteTask event, Emitter<TasksState> emit) {}

  void _onRemoveTask(RemoveTask event, Emitter<TasksState> emit) {}

  void _onMarkFavoriteOrUnfavoriteTask(
      MarkFavoriteOrUnfavoriteTask event, Emitter<TasksState> emit) {}

  void _onEditTask(EditTask event, Emitter<TasksState> emit) {}

  void _onRestoreTask(RestoreTask event, Emitter<TasksState> emit) {}

  void _onDeleteAllTask(DeleteAllTasks event, Emitter<TasksState> emit) {}

  @override
  TasksState? fromJson(Map<String, dynamic> json) {
    return TasksState.fromMap(json);
  }

  @override
  Map<String, dynamic>? toJson(TasksState state) {
    return state.toMap();
  }
}
