
package LAB07_ADA;

/**
 *
 * @author MATHIAS TORRES
 */
public class BST {
    private NodoBST raiz;
    
    //Insertar en nodo
    public void insertar(Cliente c){
        raiz = insertarRec(raiz, c);
    }
    
    private NodoBST insertarRec(NodoBST nodo, Cliente c){
        if(nodo == null){
            return new NodoBST(c);
        }
        
        String keyNodo = nodo.cliente.getApellidos() + nodo.cliente.getNombres();
        String keyC = c.getApellidos() + c.getNombres();
        
        if(keyC.compareToIgnoreCase(keyNodo) < 0){
            nodo.izquierdo = insertarRec(nodo.izquierdo, c);
        }else{
            nodo.derecho = insertarRec(nodo.derecho, c);
        }
        
        return nodo;
    }
    
    //Buscar en BST
    public Cliente buscar(String apellidos, String nombres){
        return buscarRec(raiz, apellidos + nombres);
    }
    
    private Cliente buscarRec(NodoBST nodo, String key){
        if(nodo == null){
            return null;
        }
        
        String keyNodo = nodo.cliente.getApellidos() + nodo.cliente.getNombres();
        int cmp = key.compareToIgnoreCase(keyNodo);
        
        if(cmp == 0) return nodo.cliente;
        if(cmp < 0) return buscarRec(nodo.izquierdo, key);
        else return buscarRec(nodo.derecho, key);
    }
    
}
