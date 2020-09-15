#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QtWebEngine/QtWebEngine>

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QGuiApplication app(argc, argv);

    QtWebEngine::initialize();

    qmlRegisterSingletonType(QUrl("qrc:/CustomListModel.qml"),
                             "CustomListModel",
                             1,0,
                             "CustomListModel");

    QQmlApplicationEngine engine;
    engine.addImportPath("qrc:/html/resources/");
    const QUrl url(QStringLiteral("qrc:/main.qml"));

    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);

    engine.load(url);

    return app.exec();
}
