
package LAB07_ADA;

/**
 *
 * @author MATHIAS TORRES
 */
public class TablaHashLineal {
    private Cliente[] tabla;
    private int tamaño;
    private int ocupados = 0;
    
    public TablaHashLineal(int tamaño){
        this.tamaño = tamaño;
        tabla = new Cliente[tamaño];
    }
    
    private int hash(String key) {
        // Ejemplo: sumamos los códigos ASCII de apellidos+nombres y hacemos módulo
        int sum = 0;
        for (char c : key.toCharArray()) sum += c;
        return (sum & 0x7fffffff) % tamaño;
    }
    
    public void insertar(Cliente c) {
        if (ocupados == tamaño) throw new RuntimeException("Tabla llena");
        String key = c.getApellidos() + c.getNombres();
        int idx = hash(key);
        while (tabla[idx] != null) {
            idx = (idx + 1) % tamaño;  // sondeo lineal
        }
        tabla[idx] = c;
        ocupados++;
    }
    
    public Cliente buscar(String apellidos, String nombres) {
        String key = apellidos + nombres;
        int idx = hash(key);
        int inicio = idx;
        while (tabla[idx] != null) {
            if ((tabla[idx].getApellidos()+tabla[idx].getNombres())
                  .equalsIgnoreCase(key))
                return tabla[idx];
            idx = (idx + 1) % tamaño;
            if (idx == inicio) break;  // vuelta completa
        }
        return null;
    }
    
    public double factorCarga(){
        return (double) ocupados / tamaño;
    }
}
