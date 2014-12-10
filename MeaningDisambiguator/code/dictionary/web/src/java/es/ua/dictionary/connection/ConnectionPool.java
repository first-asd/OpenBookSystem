package es.ua.dictionary.connection;

import java.sql.Connection;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

/**
 *
 * @author javi
 */
public class ConnectionPool {
 
    private String host;
    private String port;
    private String name;
    private String user;
    private String password;
    private int maxConnections;
    private List<Connection> available;
    private Set<Connection> used;

    public ConnectionPool(String host, String port, String name, String user, String password, int maxConnections) throws ClassNotFoundException {
        Class.forName("com.mysql.jdbc.Driver");
        this.host = host;
        this.port = port;
        this.name = name;
        this.user = user;
        this.password = password;
        this.maxConnections = maxConnections;
        available = Collections.synchronizedList(new ArrayList<Connection>(maxConnections));
        used = Collections.synchronizedSet(new HashSet<Connection>(maxConnections));
    }

    public final ConnectionUtils getConnection() throws SQLException {
        return sync(GET, null);
    }

    public final void releaseConnection(ConnectionUtils connection) {
        try {
            sync(RELEASE, connection);
        } catch (SQLException ex) {
            ex.printStackTrace();
        }
    }
    
    public void close() throws SQLException {
        sync(CLOSE, null);
    }
    
    private static final int GET = 0;
    private static final int RELEASE = 1;
    private static final int CLOSE = 2;

    private synchronized ConnectionUtils sync(int action, ConnectionUtils connectionUtils) throws SQLException {
        switch (action) {
            case GET: {
                while (true) {
                    if (!available.isEmpty()) {
                        Connection connection = available.remove(0);
                        if (!connection.isValid(10000)) {
                            connection.close();
                            connection = ConnectionUtils.openConnection(host, name, port, user, password);
                        }
                        used.add(connection);
                        connectionUtils = new ConnectionUtils(connection);
                        break;
                    } else if (available.size() + used.size() < maxConnections) {
                        Connection connection = ConnectionUtils.openConnection(host, name, port, user, password);
                        used.add(connection);
                        connectionUtils = new ConnectionUtils(connection);
                        break;
                    } else {
                        try {
                            wait();
                        } catch (InterruptedException ex) {
                            // Unreachable
                        }
                    }
                }
                break;
            }
            case RELEASE: {
                connectionUtils.close();
                Connection connection = connectionUtils.getConnection();
                if (used.remove(connection)) {
                    available.add(connection);
                }
                notifyAll();
                break;
            }
            case CLOSE: {
                while (true) {
                    if (!available.isEmpty()) {
                        Connection connection = available.remove(0);
                        connection.close();
                    } else if (!used.isEmpty()) {
                        try {
                            wait(1000);
                        } catch (InterruptedException ex) {
                            // Unreachable
                        }
                    } else {
                        break;
                    }
//                    System.out.println(available.size() + " - " + used.size());
                }
            }
        }
        return connectionUtils;
    }
}
