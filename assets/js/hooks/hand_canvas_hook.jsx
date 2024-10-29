import {  React, ReactDOM, THREE, Canvas, useFrame, useGLTF, Environment, Lightformer, OrbitControls} from "../externals";
// import { Canvas, useFrame } from '@react-three/fiber';

const HandCanvasHook = {
  mounted() {
    const { useRef, useState, useEffect } = React;

    function Hand({ onBoneSelect }) {
      const { nodes } = useGLTF('/assets/hands.glb');
      const handRef = useRef();

      useFrame(() => {
        // Add any updates here if needed
      });

      return (
        <group ref={handRef} onPointerDown={onBoneSelect}>
          <primitive object={nodes.Hand} />
        </group>
      );
    }

    function App() {
      const [selectedBone, setSelectedBone] = useState(null);
      const raycaster = useRef(new THREE.Raycaster());
      const mouse = useRef(new THREE.Vector2());
      const cameraRef = useRef();
      const sceneRef = useRef();

      const onBoneSelect = (event) => {
        mouse.current.x = (event.clientX / window.innerWidth) * 2 - 1;
        mouse.current.y = -(event.clientY / window.innerHeight) * 2 + 1;
        raycaster.current.setFromCamera(mouse.current, cameraRef.current);

        const intersects = raycaster.current.intersectObjects(sceneRef.current.children, true);
        if (intersects.length > 0) {
          const intersectedObject = intersects[0].object;
          if (intersectedObject.isSkinnedMesh) {
            const bone = intersectedObject.skeleton.bones.find(bone => intersectedObject.skeleton.bones.includes(bone));
            if (bone) {
              setSelectedBone(bone);
            }
          }
        }
      };

      const onPointerMove = (event) => {
        if (!selectedBone) return;

        const deltaX = event.movementX || event.mozMovementX || event.webkitMovementX || 0;
        const deltaY = event.movementY || event.mozMovementY || event.webkitMovementY || 0;

        selectedBone.rotation.x += deltaY * 0.01;
        selectedBone.rotation.y += deltaX * 0.01;
      };

      const onPointerUp = () => {
        setSelectedBone(null);
      };

      useEffect(() => {
        document.addEventListener('mousemove', onPointerMove);
        document.addEventListener('mouseup', onPointerUp);

        return () => {
          document.removeEventListener('mousemove', onPointerMove);
          document.removeEventListener('mouseup', onPointerUp);
        };
      }, [selectedBone]);

      return (
        <Canvas
          camera={{ position: [0, 0, 13], fov: 25 }}
          onCreated={({ gl, camera, scene }) => {
            cameraRef.current = camera;
            sceneRef.current = scene;
          }}
          onPointerDown={onBoneSelect}
        >
          <ambientLight intensity={Math.PI} />
          <Environment background blur={0.75}>
            <color attach="background" args={['black']} />
            <Lightformer intensity={2} color="white" position={[0, -1, 5]} rotation={[0, 0, Math.PI / 3]} scale={[100, 0.1, 1]} />
            <Lightformer intensity={3} color="white" position={[-1, -1, 1]} rotation={[0, 0, Math.PI / 3]} scale={[100, 0.1, 1]} />
            <Lightformer intensity={3} color="white" position={[1, 1, 1]} rotation={[0, 0, Math.PI / 3]} scale={[100, 0.1, 1]} />
            <Lightformer intensity={10} color="white" position={[-10, 0, 14]} rotation={[0, Math.PI / 2, Math.PI / 3]} scale={[100, 10, 1]} />
          </Environment>
          <Hand onBoneSelect={onBoneSelect} />
          <OrbitControls ref={cameraRef} />
        </Canvas>
      );
    }

    ReactDOM.createRoot(this.el).render(<App />);
  }
};

export default HandCanvasHook;
