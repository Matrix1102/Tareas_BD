
package LAB07_ADA;

/**
 *
 * @author MATHIAS TORRES
 */
public class TablaHashChainingBST {
    private BST[] tabla;
    private int tamaño;
    
    public TablaHashChainingBST(int tamaño) {
        this.tamaño = tamaño;
        tabla = new BST[tamaño];
        for (int i = 0; i < tamaño; i++)
            tabla[i] = new BST();
    }
    
    private int hash(String key) {
        int sum = 0;
        for (char c : key.toCharArray()) sum += c * 31;
        return (sum & 0x7fffffff) % tamaño;
    }
    
    public void insertar(Cliente c) {
        String key = c.getApellidos() + c.getNombres();
        int idx = hash(key);
        tabla[idx].insertar(c);
    }
    
    public Cliente buscar(String apellidos, String nombres) {
        String key = apellidos + nombres;
        int idx = hash(key);
        return tabla[idx].buscar(apellidos, nombres);
    }
}
