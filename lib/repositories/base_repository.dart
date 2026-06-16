abstract class BaseRepository<T> {

  Future<List<T>> getAll();

  Future<T?> getById(dynamic id);

  Future<int> insert(T item);

  Future<int> update(T item);

  Future<int> delete(dynamic id);

}