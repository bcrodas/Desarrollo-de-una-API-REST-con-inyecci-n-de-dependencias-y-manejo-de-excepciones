package com.tienda.productos.excepcion;

public class ProductoNoEncontradoException extends RuntimeException {

    public ProductoNoEncontradoException(Long id) {
        super("No se encontro el producto con id " + id + ".");
    }
}
