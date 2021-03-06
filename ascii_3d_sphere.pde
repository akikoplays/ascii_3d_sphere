/**
This is just some idea for the amiga intro, basically you generate a dot sphere with n segments, 
toss some quick vec3 math functions, and simple, fixed camera 3d => 2d projection. To make it a
bit more retro, I just replaced the original dot renderer with ascii renderer that picks up different
letters based on the illumination factor. The light originates at camera position, but can easily be
placed anywhere else, and colored.
p.s. I am intentionally not using any matrix math nor p3d, since I just wanted to have some fun with 
manually written calculations.
boris posavec, march 2021.
*/

class vec3 {
  vec3(float x, float y, float z) 
  {
    this.x = x;
    this.y = y;
    this.z = z;
  }
 
  float x;
  float y;
  float z;
};

vec3 vec3_normalize(vec3 v)
{
  float len = sqrt(v.x * v.x + v.y * v.y + v.z * v.z);
  return new vec3(v.x / len, v.y / len, v.z / len);
}

vec3 vec3_add(vec3 v1, vec3 v2) 
{
  return new vec3(v1.x + v2.x, v1.y + v2.y, v2.z + v2.z);
}

vec3 vec3_sub(vec3 v1, vec3 v2) 
{
  return new vec3(v1.x - v2.x, v1.y - v2.y, v1.z - v2.z);
}

float vec3_dot(vec3 v1, vec3 v2)
{
  return v1.x * v2.x + v1.y * v2.y + v1.z * v2.z;
}

ArrayList<vec3> createDotSphere(float r)
{
  ArrayList<vec3> pts = new ArrayList<vec3>(); 

  float sectorCount = 32;
  float stackCount = 32; 
  float sectorStep = 2 * PI / sectorCount;
  float stackStep = PI / stackCount;
  float stackAngle = 0.0f, sectorAngle = 0.0f;
  for (int i = 0; i < stackCount; ++i) {
      stackAngle = PI / 2 - i * stackStep;
      float xy = r * cos(stackAngle);
      float z = r * sin(stackAngle);
      
      for (int j = 0; j < sectorCount; ++j) {
        sectorAngle = j * sectorStep;
        
        float x = xy * cos(sectorAngle);
        float y = xy * sin(sectorAngle);
        
        pts.add(new vec3(x, y, z));
      }
  } 
  return pts;
}

vec3 rotateX(vec3 p, float angle) 
{
   float cos = cos(angle);
   float sin = sin(angle);
   float nx = p.x;
   float ny = p.y * cos + p.z * sin;
   float nz = - p.y * sin + p.z * cos;
   return new vec3(nx, ny, nz);
}

vec3 rotateY(vec3 p, float angle)
{
   float cos = cos(angle);
   float sin = sin(angle);
   float nx = p.x * cos - p.z * sin;
   float ny = p.y;
   float nz = p.x * sin + p.z * cos;
   return new vec3(nx, ny, nz);
}

vec3 projectFixed(vec3 p, float d)
{
  return new vec3(p.x * d / p.z, p.y * d / p.z, p.z);
}

final float zoom = 0.45f;
final ArrayList<vec3> sphere = createDotSphere(10.0f);
final String shades = ".,-~:;=!*#$@";
vec3 spherePos = new vec3(0, 0, 20);
float angle = 0.0f;

void render()
{
  float ratio = (float)height / (float)width;
  angle += 0.02f;
  spherePos.z = 20.0f + sin(millis() * 0.004f) * cos(millis() * 0.001f) * 5.0f;

  // Apply translation & rotation to the sphere vertices, then render
  for (vec3 v: sphere) {   
    vec3 p = rotateX(v, angle);
    p = rotateY(p, angle * 0.5f);
    p.x += spherePos.x;
    p.y += spherePos.y;
    p.z += spherePos.z;

    if (p.z < zoom) {
      continue;
    }

    vec3 proj = projectFixed(p, zoom);
    int x = (int)(proj.x * width * ratio + width / 2);
    int y = (int)(proj.y * height + height / 2);
    
    vec3 normal = vec3_normalize(vec3_sub(p, spherePos));
    
    // Skip all points backfacing from us
    if (normal.z > 0.0f) {
      continue;
    }
    
    vec3 lightPos = new vec3(0,0,0);
    vec3 lightDir = vec3_normalize(vec3_sub(lightPos, p));
    
    float diffuse = vec3_dot(normal, lightDir);
    if (diffuse <= 0.0f) {
      continue;
    }
       
    // Version 1: render shaded dots
    //strokeWeight(10.0f * diffuse);
    //stroke(color(255.0f * diffuse));
    //point(x, y);

    // Version 2: render letters
    fill(255.0f * diffuse);
    float brightness = map(diffuse * 255.0f, 0.0f, 255.0f, 0.0f, (float)shades.length() - 1);
    char letter = shades.charAt(round(brightness));
    text(letter, x, y);
  } 
  
  return;
}

void setup()
{
  size(640, 400);
  return;
}

void draw()
{
  background(color(0,0,32));
  render();
  return;
}
