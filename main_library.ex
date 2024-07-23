defmodule Library do
  defmodule Book do
    defstruct title: "", author: "", isbn: "", available: true
  end

  defmodule User do
    defstruct name: "", id: "", borrowed_books: []
  end

  def add_book(library, %Book{} = book) do
    library ++ [book]
  end

  def add_user(users, %User{} = user) do
    users ++ [user]
  end

  def borrow_book(library, users, user_id, isbn) do
    user = Enum.find(users, &(&1.id == user_id))
    book = Enum.find(library, &(&1.isbn == isbn && &1.available))

    cond do
      user == nil -> {:error, "Usuario no encontrado"}
      book == nil -> {:error, "Libro no disponible"}
      true ->
        updated_book = %{book | available: false}
        updated_user = %{user | borrowed_books: user.borrowed_books ++ [updated_book]}

        updated_library = Enum.map(library, fn
          b when b.isbn == isbn -> updated_book
          b -> b
        end)

        updated_users = Enum.map(users, fn
          u when u.id == user_id -> updated_user
          u -> u
        end)

        {:ok, updated_library, updated_users}
    end
  end

  def return_book(library, users, user_id, isbn) do
    user = Enum.find(users, &(&1.id == user_id))
    book = Enum.find(user.borrowed_books, &(&1.isbn == isbn))

    cond do
      user == nil -> {:error, "Usuario no encontrado"}
      book == nil -> {:error, "Libro no encontrado en los libros prestados del usuario"}
      true ->
        updated_book = %{book | available: true}
        updated_user = %{user | borrowed_books: Enum.filter(user.borrowed_books, &(&1.isbn != isbn))}

        updated_library = Enum.map(library, fn
          b when b.isbn == isbn -> updated_book
          b -> b
        end)

        updated_users = Enum.map(users, fn
          u when u.id == user_id -> updated_user
          u -> u
        end)

        {:ok, updated_library, updated_users}
    end
  end

  def list_books(library) do
    library
  end

  def list_users(users) do
    users
  end

  def books_borrowed_by_user(users, user_id) do
    user = Enum.find(users, &(&1.id == user_id))
    if user, do: user.borrowed_books, else: []
  end


  def add_due_date_to_book(library, isbn, due_date) do
    updated_library = Enum.map(library, fn
      book when book.isbn == isbn -> %{book | due_date: due_date}
      book -> book
    end)
    updated_library
  end

  def overdue_books(library, users, current_date) do
    Enum.flat_map(users, fn user ->
      Enum.filter(user.borrowed_books, fn book ->
        Date.compare(book.due_date, current_date) == :lt
      end)
    end)
  end

  # Use process from console
  def run do
    loop([], [])
  end

  defp loop(library, users) do
    IO.puts("""
    Gestor de Inventario
    1. Agregar libro
    2. Agregar usuario
    3. Prestar libro
    4. Devolver libro
    5. Listar libros
    6. Listar usuarios
    7. Libros prestados por usuario
    8. Añadir fecha de vencimiento a un libro prestado
    9. Listar libros vencidos
    0. Salir
    """)

    IO.write("Seleccione una opción: ")
    option = IO.gets("") |> String.trim() |> String.to_integer()

    case option do
      1 ->
        title = IO.gets("Título: ") |> String.trim()
        author = IO.gets("Autor: ") |> String.trim()
        isbn = IO.gets("ISBN: ") |> String.trim()

        book = %Book{title: title, author: author, isbn: isbn}
        updated_library = Library.add_book(library, book)
        IO.puts("Libro agregado exitosamente")
        loop(updated_library, users)

      2 ->
        name = IO.gets("Nombre: ") |> String.trim()
        id = IO.gets("ID: ") |> String.trim()

        user = %User{name: name, id: id}
        updated_users = Library.add_user(users, user)
        IO.puts("Usuario agregado exitosamente")
        loop(library, updated_users)

      3 ->
        user_id = IO.gets("ID del usuario: ") |> String.trim()
        isbn = IO.gets("ISBN del libro: ") |> String.trim()

        case Library.borrow_book(library, users, user_id, isbn) do
          {:ok, updated_library, updated_users} ->
            IO.puts("Libro prestado exitosamente")
            loop(updated_library, updated_users)

          {:error, message} ->
            IO.puts("Error: #{message}")
            loop(library, users)
        end

      4 ->
        user_id = IO.gets("ID del usuario: ") |> String.trim()
        isbn = IO.gets("ISBN del libro: ") |> String.trim()

        case Library.return_book(library, users, user_id, isbn) do
          {:ok, updated_library, updated_users} ->
            IO.puts("Libro devuelto exitosamente")
            loop(updated_library, updated_users)

          {:error, message} ->
            IO.puts("Error: #{message}")
            loop(library, users)
        end

      5 ->
        IO.puts("Libros en la biblioteca:")
        Enum.each(library, fn book ->
          IO.puts("Título: #{book.title}, Autor: #{book.author}, ISBN: #{book.isbn}, Disponible: #{book.available}")
        end)
        loop(library, users)

      6 ->
        IO.puts("Usuarios en la biblioteca:")
        Enum.each(users, fn user ->
          IO.puts("Nombre: #{user.name}, ID: #{user.id}")
        end)
        loop(library, users)

      7 ->
        user_id = IO.gets("ID del usuario: ") |> String.trim()
        case Library.books_borrowed_by_user(users, user_id) do
          [] -> IO.puts("No se encontraron libros prestados para este usuario")
          borrowed_books ->
            IO.puts("Libros prestados por el usuario:")
            Enum.each(borrowed_books, fn book ->
              IO.puts("Título: #{book.title}, Autor: #{book.author}, ISBN: #{book.isbn}")
            end)
        end
        loop(library, users)

      8 ->
        isbn = IO.gets("ISBN del libro: ") |> String.trim()
        due_date = IO.gets("Fecha de vencimiento (YYYY-MM-DD): ") |> String.trim() |> Date.from_iso8601!()

        updated_library = Library.add_due_date_to_book(library, isbn, due_date)
        IO.puts("Fecha de vencimiento agregada exitosamente")
        loop(updated_library, users)

      9 ->
        current_date = IO.gets("Fecha actual (YYYY-MM-DD): ") |> String.trim() |> Date.from_iso8601!()
        overdue_books = Library.overdue_books(library, users, current_date)

        if overdue_books == [] do
          IO.puts("No hay libros vencidos")
        else
          IO.puts("Libros vencidos:")
          Enum.each(overdue_books, fn book ->
            IO.puts("Título: #{book.title}, Autor: #{book.author}, ISBN: #{book.isbn}, Fecha de vencimiento: #{book.due_date}")
          end)
        end
        loop(library, users)

      0 ->
        IO.puts("¡Adiós!")
        :ok

      _ ->
        IO.puts("Opción inválida")
        loop(library, users)

    end
  end
end

# Ejecutar el gestor de inventario
Library.run()
