package com.tienda.productos.servicio;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import org.springframework.stereotype.Service;

import com.tienda.productos.excepcion.ProductoInvalidoException;
import com.tienda.productos.excepcion.ProductoNoEncontradoException;
import com.tienda.productos.modelo.Producto;

@Service
public class ProductoService {

    private final Map<Long, Producto> productos = new LinkedHashMap<>();
    private long siguienteId = 1;

    public synchronized List<Producto> obtenerTodos() {
        return new ArrayList<>(productos.values());
    }

    public synchronized Producto obtenerPorId(Long id) {
        Producto producto = productos.get(id);
        if (producto == null) {
            throw new ProductoNoEncontradoException(id);
        }
        return producto;
    }

    public synchronized Producto registrar(Producto producto) {
        validar(producto);
        Producto nuevo = new Producto(siguienteId++, producto.nombre().trim(), producto.precio(), producto.stock());
        productos.put(nuevo.id(), nuevo);
        return nuevo;
    }

    public synchronized void eliminar(Long id) {
        if (productos.remove(id) == null) {
            throw new ProductoNoEncontradoException(id);
        }
    }

    private void validar(Producto producto) {
        if (producto == null) {
            throw new ProductoInvalidoException("Debe enviar un producto.");
        }
        if (producto.nombre() == null || producto.nombre().isBlank()) {
            throw new ProductoInvalidoException("El nombre es obligatorio.");
        }
        if (producto.precio() == null || producto.precio().compareTo(BigDecimal.ZERO) <= 0) {
            throw new ProductoInvalidoException("El precio debe ser mayor que cero.");
        }
        if (producto.stock() == null || producto.stock() < 0) {
            throw new ProductoInvalidoException("El stock debe ser un entero mayor o igual a cero.");
        }
    }
}
