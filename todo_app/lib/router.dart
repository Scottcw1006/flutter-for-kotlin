import 'package:go_router/go_router.dart';

import 'screens/todo_detail_screen.dart';
import 'screens/todo_list_screen.dart';

// [snippet:todo-router]
GoRouter createRouter() => GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const TodoListScreen(),
          routes: [
            GoRoute(
              path: 'todo/:id',
              builder: (context, state) =>
                  TodoDetailScreen(id: int.parse(state.pathParameters['id']!)),
            ),
          ],
        ),
      ],
    );
// [/snippet]
