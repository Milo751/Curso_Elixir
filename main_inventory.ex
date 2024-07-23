defmodule InventoryManager do
  defstruct products: [], cart: []

  def add_product(%InventoryManager{products: products} = inventory_manager, name, price, stock) do
    id = Enum.count(products) + 1
    product = %{id: id, name: name, price: price, stock: stock}
    %{inventory_manager | products: products ++ [product]}
  end

  def list_product(%InventoryManager{products: products}) do
    Enum.each(products, fn product ->
      IO.puts("#{product.id}. #{product.name} #{product.price} #{product.stock}")
    end)
  end

  def increase_stock(%InventoryManager{products: products} = inventory_manager, id, quantity) do
    updated_stock = Enum.map(products, fn product ->
      if product.id == id do
        %{product | stock: product.stock + quantity}
      else
        product
      end
    end)
    %{inventory_manager | products: updated_stock}
  end

  def sell_product(%InventoryManager{products: products, cart: cart} = inventory_manager, id, quantity) do
    case Enum.find(products, fn product -> product.id == id end) do
      nil ->
        IO.puts("Product not found.")
        inventory_manager
      product when product.stock < quantity ->
        IO.puts("Not enough stock for product #{product.name}.")
        inventory_manager
      product ->
        updated_products = %{p | stock: p.stock - quantity}
        updated_cart = cart ++ [{id, quantity}]

        %{inventory_manager | products: updated_products, cart: updated_cart}
    end
  end

  def view_cart(%InventoryManager{cart: cart}) do
    Enum.each(cart, fn {id, quantity} ->
      product = Enum.find(inventory_manager.products, fn product -> product.id == id end)
      IO.puts("Product ID: #{id}, Name: #{product.name}, Quantity: #{quantity}, Price: #{product.price}, Total: #{product.price * quantity}")
    end)
  end

  def checkout(%InventoryManager{cart: cart} = inventory_manager) do
    total_cost = Enum.reduce(cart, 0, fn {id, quantity}, acc ->
      product = Enum.find(inventory_manager.products, fn product -> product.id == id end)
      acc + product.price * quantity
    end)

    IO.puts("Total cost: #{total_cost}")

    %{inventory_manager | cart: []}
  end

  def run do
    inventory_manager = %InventoryManager{}
    loop(inventory_manager)
  end

  defp loop(inventory_manager) do
    IO.puts("""
    Gestor de Inventario
    1. Agregar Producto
    2. Listar Producto
    3. Aumentar Stock
    4. Vender Producto
    5. Mirar carrito
    6. Pagar
    7. Salir
    """)

    IO.write("Seleccione una opción: ")
    option = IO.gets("") |> String.trim() |> String.to_integer()

    case option do
      1 ->
        IO.write("Ingrese la informacion del producto (nombre, precio, cantidad): ")
        name = IO.gets("") |> String.trim()
        price = IO.gets("") |> String.trim() |> String.to_float()
        stock = IO.gets("") |> String.trim() |> String.to_integer()
        inventory_manager = add_product(inventory_manager, name, price, stock)
        loop(inventory_manager)

      2 ->
        list_product(inventory_manager)
        loop(inventory_manager)

      3 ->
        IO.write("Ingrese el ID y la cantidad del producto que desea aumentar: ")
        id = IO.gets("") |> String.trim() |> String.to_integer()
        quantity = IO.gets("") |> String.trim() |> String.to_integer()
        inventory_manager = increase_stock(inventory_manager, id, quantity)
        loop(inventory_manager)

      4 ->
        IO.write("Ingrese el ID y la cantidad del producto que desea vender: ")
        id = IO.gets("") |> String.trim() |> String.to_integer()
        quantity = IO.gets("") |> String.trim() |> String.to_integer()
        inventory_manager = sell_product(inventory_manager, id, quantity)
        loop(inventory_manager)

      5 ->
        IO.puts("Productos en el carrito: ")
        inventory_manager = view_cart(inventory_manager)
        loop(inventory_manager)

      6 ->
        IO.puts("Pagar: ")
        inventory_manager = checkout(inventory_manager)
        loop(inventory_manager)

      7 ->
        IO.puts("¡Adiós!")
        :ok

      _ ->
        IO.puts("Opción no válida.")
        loop(task_manager)
    end
  end
end

# Ejecutar el gestor de inventario
InventoryManager.run()
