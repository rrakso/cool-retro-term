#ifndef CONTROLSERVER_H
#define CONTROLSERVER_H

#include <QHostAddress>
#include <QMap>
#include <QObject>
#include <QTcpServer>
#include <QTcpSocket>

// Small line-based TCP control server used to tweak render parameters at
// runtime (e.g. from a Python script). Networking lives here; the actual
// parameter logic stays in QML, where the settings properties live.
//
// The server emits commandReceived() synchronously for every '\n'-terminated
// line. The QML handler parses the line and may call reply() to answer the
// client that issued the command currently being processed.
class ControlServer : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool listening READ isListening NOTIFY listeningChanged)

public:
    explicit ControlServer(QObject *parent = nullptr);

    // Start listening. Binds to the loopback interface by default so the
    // terminal's look can only be driven by local processes.
    bool listen(quint16 port, const QHostAddress &address = QHostAddress::LocalHost);
    bool isListening() const;

    // Send a line back to the client whose command is currently being handled.
    // A trailing newline is appended if missing. No-op outside command handling.
    Q_INVOKABLE void reply(const QString &text);

signals:
    void commandReceived(const QString &line);
    void listeningChanged();

private slots:
    void onNewConnection();
    void onReadyRead();
    void onDisconnected();

private:
    QTcpServer m_server;
    QMap<QTcpSocket *, QByteArray> m_buffers;
    QTcpSocket *m_currentClient = nullptr;
};

#endif // CONTROLSERVER_H
