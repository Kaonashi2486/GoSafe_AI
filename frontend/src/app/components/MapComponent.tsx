import { useEffect } from "react";
import tt from "@tomtom-international/web-sdk-maps";
import "@tomtom-international/web-sdk-maps/dist/maps.css";

interface Point {
    coordinates: [number, number];
    properties: { id: number; name: string };
}

interface MapComponentProps {
    points: Point[];
    location: "Mumbai" | "Pune"; // Preset locations
}

const MapComponent: React.FC<MapComponentProps> = ({ points, location }) => {
    const locationCoordinates: { [key: string]: [number, number] } = {
        Mumbai: [72.8777, 19.0760],
        Pune: [73.8567, 18.5204],
    };

    useEffect(() => {
        const map = tt.map({
            key: "5S942FW5vWvlAV9u2hGGEqGUniBut2X9",
            container: "map",
            center: locationCoordinates[location] || [72.8777, 19.0760], // Default to Mumbai if location is unknown
            zoom: 10,
        });

        map.addControl(new tt.FullscreenControl());
        map.addControl(new tt.NavigationControl());

        const geoJson: GeoJSON.FeatureCollection = {
            type: "FeatureCollection",
            features: points.map((point) => ({
                type: "Feature",
                geometry: {
                    type: "Point",
                    coordinates: point.coordinates as [number, number],
                },
                properties: point.properties,
            })),
        };

        map.on("load", () => {
            map.addSource("point-source", {
                type: "geojson",
                data: geoJson,
                cluster: true,
                clusterMaxZoom: 14,
                clusterRadius: 50,
            });

            map.addLayer({
                id: "clusters",
                type: "circle",
                source: "point-source",
                filter: ["has", "point_count"],
                paint: {
                    "circle-color": ["step", ["get", "point_count"], "#EC619F", 4, "#008D8D", 7, "#004B7F"],
                    "circle-radius": ["step", ["get", "point_count"], 15, 4, 20, 7, 25],
                    "circle-stroke-width": 1,
                    "circle-stroke-color": "white",
                    "circle-stroke-opacity": 1,
                },
            });

            map.addLayer({
                id: "cluster-count",
                type: "symbol",
                source: "point-source",
                filter: ["has", "point_count"],
                layout: {
                    "text-field": "{point_count_abbreviated}",
                    "text-size": 16,
                },
                paint: {
                    "text-color": "white",
                },
            });

            points.forEach((point) => {
                const marker = new tt.Marker().setLngLat(point.coordinates).addTo(map);
                marker.setPopup(new tt.Popup({ offset: 30 }).setText(point.properties.name));
            });

            map.on("click", "clusters", (e) => {
                const features = map.queryRenderedFeatures(e.point, { layers: ["clusters"] }) as tt.GeoJSONFeature[];

                if (!features.length) return;

                const clusterId = features[0].properties?.cluster_id;
                if (clusterId === undefined) return;

                const source = map.getSource("point-source");
                if (!source || !("getClusterExpansionZoom" in source)) return;

                (source as tt.GeoJSONSource).getClusterExpansionZoom(clusterId, (err, zoom) => {
                    if (err || !features[0].geometry || features[0].geometry.type !== "Point") return;

                    map.easeTo({
                        center: features[0].geometry.coordinates as [number, number],
                        zoom: zoom + 0.5,
                    });
                });
            });

            map.on("mouseenter", "clusters", () => {
                map.getCanvas().style.cursor = "pointer";
            });

            map.on("mouseleave", "clusters", () => {
                map.getCanvas().style.cursor = "";
            });
        });

        return () => map.remove();
    }, [points, location]);

    return <div id="map" style={{ width: "100%", height: "500px" }} />;
};

export default MapComponent;
